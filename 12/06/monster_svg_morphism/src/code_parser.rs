use std::path::{Path};
use walkdir::WalkDir;
use syn::{Item, ItemFn, ItemStruct, ItemEnum, ItemMod};
// quote::quote is not directly used in this version of the parser
// syn::File is also not directly used as parse_file returns syn::File directly

/// Represents a detected declaration in the Rust code.
#[derive(Debug, Clone)]
pub struct DeclarationInfo {
    pub decl_type: String, // e.g., "fn", "struct", "enum", "mod"
    pub full_path: String, // e.g., "crate_name::module_name::MyStruct::my_method"
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
}

// Implement a simplified visitor pattern for clarity.
impl DeclarationCollector {
    fn visit_item(&mut self, item: &Item) {
        match item {
            Item::Fn(ItemFn { sig, .. }) => { // Corrected: access ident via sig
                self.declarations.push(DeclarationInfo {
                    decl_type: "fn".to_string(),
                    full_path: self.get_full_path(&sig.ident.to_string()),
                });
            }
            Item::Struct(ItemStruct { ident, .. }) => {
                self.declarations.push(DeclarationInfo {
                    decl_type: "struct".to_string(),
                    full_path: self.get_full_path(&ident.to_string()),
                });
            }
            Item::Enum(ItemEnum { ident, .. }) => {
                self.declarations.push(DeclarationInfo {
                    decl_type: "enum".to_string(),
                    full_path: self.get_full_path(&ident.to_string()),
                });
            }
            Item::Mod(ItemMod { ident, content, .. }) => {
                let module_name = ident.to_string();
                self.declarations.push(DeclarationInfo {
                    decl_type: "mod".to_string(),
                    full_path: self.get_full_path(&module_name),
                });

                self.push_path_segment(&module_name);
                if let Some((_, items)) = content {
                    for item in items {
                        self.visit_item(item);
                    }
                }
                self.pop_path_segment();
            }
            // Add other item types as needed (e.g., ItemTrait, ItemImpl)
            _ => {
                // For now, ignore other item types to keep it focused on user's request
            }
        }
    }
}


/// Collects declarations from all Rust files within a given directory.
pub fn collect_declarations_from_dir(path: &Path) -> Vec<DeclarationInfo> {
    let mut all_declarations = Vec::new();

    // Start with the crate root as a path segment
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
        collector.push_path_segment(&crate_name); // Initialize with crate name

        // Determine module path based on file system structure
        if let Some(relative_path) = file_path.strip_prefix(path).ok() {
            let mut module_path_segments: Vec<String> = relative_path
                .parent() // Get directory relative to crate root
                .unwrap_or(Path::new(""))
                .iter()
                .filter_map(|s| s.to_str().map(|s_str| s_str.to_string()))
                .collect();

            // Handle `lib.rs` and `main.rs` as root modules
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