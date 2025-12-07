use std::path::{Path};
use walkdir::WalkDir;
use syn::{Item, ItemFn, ItemStruct, ItemEnum, ItemMod, Type, Fields}; // Removed Field, Variant
use quote::ToTokens; // Use ToTokens for converting syn types to string

/// Represents a detected field within a struct.
#[derive(Debug, Clone)]
pub struct FieldInfo {
    pub name: String,
    pub type_name: String, // String representation of the field's type (e.g., "String", "MyStruct", "Option<T>")
}

/// Represents a variant within an enum.
#[derive(Debug, Clone)]
pub struct VariantInfo {
    pub name: String,
    pub field_types: Vec<String>, // String representations of types for tuple/struct variants
}

/// Represents a detected declaration in the Rust code.
#[derive(Debug, Clone)]
pub struct DeclarationInfo {
    pub decl_type: String, // e.g., "fn", "struct", "enum", "mod"
    pub full_path: String, // e.g., "crate_name::module_name::MyStruct::my_method"
    pub fields: Vec<FieldInfo>, // For structs, holds field details
    pub variants: Vec<VariantInfo>, // For enums, holds variant details
}

impl DeclarationInfo {
    fn new(decl_type: String, full_path: String) -> Self {
        DeclarationInfo {
            decl_type,
            full_path,
            fields: Vec::new(),
            variants: Vec::new(),
        }
    }
}


/// A custom visitor to collect declarations.
struct DeclarationCollector {
    declarations: Vec<DeclarationInfo>,
    current_path_segments: Vec<String>,
}

impl DeclarationCollector {
    fn new() -> Self {
        DeclarationCollector {
            declarations: Vec::new(),
            current_path_segments: Vec::new(),
        }
    }

    fn push_path_segment(&mut self, segment: &str) {
        self.current_path_segments.push(segment.to_string());
    }

    fn pop_path_segment(&mut self) {
        self.current_path_segments.pop();
    }

    fn get_full_path(&self, name: &str) -> String {
        let mut path = self.current_path_segments.join("::");
        if !path.is_empty() {
            path.push_str("::");
        }
        path.push_str(name);
        path
    }

    fn get_type_string(ty: &Type) -> String {
        ty.to_token_stream().to_string().replace(" ", "") // Convert syn::Type to String, remove spaces
    }
}

// Implement a simplified visitor pattern for clarity.
impl DeclarationCollector {
    fn visit_item(&mut self, item: &Item) {
        match item {
            Item::Fn(ItemFn { sig, .. }) => {
                self.declarations.push(DeclarationInfo::new(
                    "fn".to_string(),
                    self.get_full_path(&sig.ident.to_string()),
                ));
            }
            Item::Struct(ItemStruct { ident, fields, .. }) => {
                let mut decl_info = DeclarationInfo::new(
                    "struct".to_string(),
                    self.get_full_path(&ident.to_string()),
                );
                for field in fields {
                    if let Some(field_name) = &field.ident {
                        decl_info.fields.push(FieldInfo {
                            name: field_name.to_string(),
                            type_name: Self::get_type_string(&field.ty),
                        });
                    }
                }
                self.declarations.push(decl_info);
            }
            Item::Enum(ItemEnum { ident, variants, .. }) => {
                let mut decl_info = DeclarationInfo::new(
                    "enum".to_string(),
                    self.get_full_path(&ident.to_string()),
                );
                for variant in variants {
                    let mut field_types = Vec::new();
                    match &variant.fields {
                        Fields::Named(fields_named) => {
                            for field in &fields_named.named {
                                field_types.push(Self::get_type_string(&field.ty));
                            }
                        },
                        Fields::Unnamed(fields_unnamed) => {
                            for field in &fields_unnamed.unnamed {
                                field_types.push(Self::get_type_string(&field.ty));
                            }
                        },
                        Fields::Unit => {}, // Unit variant, no fields
                    }
                    decl_info.variants.push(VariantInfo {
                        name: variant.ident.to_string(),
                        field_types,
                    });
                }
                self.declarations.push(decl_info);
            }
            Item::Mod(ItemMod { ident, content, .. }) => {
                let module_name = ident.to_string();
                self.declarations.push(DeclarationInfo::new(
                    "mod".to_string(),
                    self.get_full_path(&module_name),
                ));

                self.push_path_segment(&module_name);
                if let Some((_, items)) = content {
                    for item in items {
                        self.visit_item(item);
                    }
                }
                self.pop_path_segment();
            }
            _ => {
                // Ignore other item types for now
            }
        }
    }
}


/// Collects declarations from all Rust files within a given directory.
pub fn collect_declarations_from_dir(path: &Path) -> Vec<DeclarationInfo> {
    let mut all_declarations = Vec::new();

    let crate_name = path.file_name().and_then(|s| s.to_str()).unwrap_or("crate").to_string();

    for entry in WalkDir::new(path)
        .into_iter()
        .filter_map(|e| e.ok())
        .filter(|e| e.file_type().is_file() && e.path().extension().map_or(false, |ext| ext == "rs"))
    {
        let file_path = entry.path();
        let file_content = std::fs::read_to_string(file_path).unwrap_or_default();

        let ast = syn::parse_file(&file_content).expect("Failed to parse Rust file");

        let mut collector = DeclarationCollector::new();
        collector.push_path_segment(&crate_name);

        if let Some(relative_path) = file_path.strip_prefix(path).ok() {
            let mut module_path_segments: Vec<String> = relative_path
                .parent()
                .unwrap_or(Path::new(""))
                .iter()
                .filter_map(|s| s.to_str().map(|s_str| s_str.to_string()))
                .collect();

            if relative_path.file_name().map_or(false, |f| f == "lib.rs" || f == "main.rs") {
                // No additional module segment
            } else if let Some(file_stem) = relative_path.file_stem().and_then(|s| s.to_str()) {
                module_path_segments.push(file_stem.to_string());
            }

            for segment in module_path_segments {
                collector.push_path_segment(&segment);
            }
        }

        for item in ast.items {
            collector.visit_item(&item);
        }

        all_declarations.extend(collector.declarations);
    }
    all_declarations
}