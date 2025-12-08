use std::path::{Path};
use walkdir::WalkDir;
use syn::{Item, Type, Fields, ImplItem}; // Simplified imports
use quote::ToTokens; // Use ToTokens for converting syn types to string

#[derive(Debug, Clone, PartialEq, Eq, Hash)]
pub enum CodeElementKind {
    Crate,
    Module,
    Function,
    Struct,
    Enum,
    Method, // A method associated with an impl block
    Const,    // A constant item (const)
    Static,   // A static item (static)
    Field,    // A field within a struct
    Variant,  // A variant within an enum
    Parameter, // A parameter in a function signature
    ReturnType, // A return type in a function signature
    UsedType, // A type used in a field, parameter, or return type context
}

#[derive(Debug, Clone)]
pub struct CodeElementInfo {
    pub id: usize, // A unique ID for this element
    pub kind: CodeElementKind,
    pub name: String, // Simple name (e.g., "MyStruct", "my_function", "field_name")
    pub full_path: String, // e.g., "crate_name::module_name::MyStruct::my_function"
    pub parent_full_path: Option<String>, // Full path of its direct parent
    pub type_name: Option<String>, // For fields, parameters, return types, const/static
    pub associated_idents: Vec<String>, // e.g., field names for a struct, variant names for an enum, parameter names
    pub related_types: Vec<String>, // e.g., field types for a struct, fn param types, fn return type, variant types
}

impl CodeElementInfo {
    fn new(id: usize, kind: CodeElementKind, name: String, full_path: String, parent_full_path: Option<String>) -> Self {
        CodeElementInfo {
            id,
            kind,
            name,
            full_path,
            parent_full_path,
            type_name: None,
            associated_idents: Vec::new(),
            related_types: Vec::new(),
        }
    }
}

/// A custom visitor to collect code elements.
struct CodeElementCollector {
    elements: Vec<CodeElementInfo>,
    current_path_segments: Vec<String>,
    next_id: usize,
}

impl CodeElementCollector {
    fn new() -> Self {
        CodeElementCollector {
            elements: Vec::new(),
            current_path_segments: Vec::new(),
            next_id: 0,
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

    fn get_current_parent_path(&self) -> Option<String> {
        if self.current_path_segments.is_empty() {
            None
        } else {
            Some(self.current_path_segments.join("::"))
        }
    }

    fn get_type_string(ty: &Type) -> String {
        ty.to_token_stream().to_string().replace(" ", "") // Convert syn::Type to String, remove spaces
    }

    // This function now returns the ID of the newly added element
    fn add_element_and_get_id(&mut self, kind: CodeElementKind, name: String, parent_path: Option<String>) -> usize {
        let full_path = self.get_full_path(&name);
        let id = self.next_id;
        self.next_id += 1;
        self.elements.push(CodeElementInfo::new(id, kind, name, full_path, parent_path));
        id
    }
}

// Implement a simplified visitor pattern for clarity.
impl CodeElementCollector {
    fn visit_item(&mut self, item: &Item) {
        let parent_path = self.get_current_parent_path();
        match item {
            Item::Fn(item_fn) => {
                let func_name = item_fn.sig.ident.to_string();
                let func_full_path = self.get_full_path(&func_name);
                let func_parent_path = parent_path.clone();

                let mut associated_idents: Vec<String> = Vec::new();
                let mut related_types: Vec<String> = Vec::new();

                // Process parameters and their types
                for input in &item_fn.sig.inputs {
                    if let syn::FnArg::Typed(pat_type) = input {
                        let param_name = pat_type.pat.to_token_stream().to_string();
                        let param_type_str = Self::get_type_string(&pat_type.ty);

                        associated_idents.push(param_name.clone());
                        related_types.push(param_type_str.clone());

                        // Add parameter element
                        let param_element_id = self.add_element_and_get_id(
                            CodeElementKind::Parameter,
                            param_name,
                            Some(func_full_path.clone()),
                        );
                        self.elements.get_mut(param_element_id).unwrap().type_name = Some(param_type_str.clone());

                        // Add used type element
                        let used_type_element_id = self.add_element_and_get_id(
                            CodeElementKind::UsedType,
                            param_type_str.clone(),
                            Some(func_full_path.clone()),
                        );
                        self.elements.get_mut(used_type_element_id).unwrap().type_name = Some(param_type_str);
                    }
                }
                // Process return type
                if let syn::ReturnType::Type(_, ty) = &item_fn.sig.output {
                    let return_type_str = Self::get_type_string(ty);
                    related_types.push(return_type_str.clone());

                    // Add return type element
                    let return_element_id = self.add_element_and_get_id(
                        CodeElementKind::ReturnType,
                        return_type_str.clone(),
                        Some(func_full_path.clone()),
                    );
                    self.elements.get_mut(return_element_id).unwrap().type_name = Some(return_type_str.clone());

                    // Add used type element
                    let used_type_element_id = self.add_element_and_get_id(
                        CodeElementKind::UsedType,
                        return_type_str.clone(),
                        Some(func_full_path.clone()),
                    );
                    self.elements.get_mut(used_type_element_id).unwrap().type_name = Some(return_type_str);
                }

                // Finally, add the function element itself and populate its associated data
                let func_id = self.add_element_and_get_id(
                    CodeElementKind::Function,
                    func_name,
                    func_parent_path,
                );
                let func_info = self.elements.get_mut(func_id).unwrap();
                func_info.associated_idents = associated_idents;
                func_info.related_types = related_types;
            }
            Item::Struct(item_struct) => {
                let struct_name = item_struct.ident.to_string();
                let struct_full_path = self.get_full_path(&struct_name);
                let struct_parent_path = parent_path.clone();

                let mut associated_idents: Vec<String> = Vec::new();
                let mut related_types: Vec<String> = Vec::new();

                for field in &item_struct.fields {
                    if let Some(field_name) = &field.ident {
                        let field_type_str = Self::get_type_string(&field.ty);
                        associated_idents.push(field_name.to_string());
                        related_types.push(field_type_str.clone());

                        // Add field as a separate element
                        let field_element_id = self.add_element_and_get_id(
                            CodeElementKind::Field,
                            field_name.to_string(),
                            Some(struct_full_path.clone()),
                        );
                        self.elements.get_mut(field_element_id).unwrap().type_name = Some(field_type_str.clone());

                        // Add used type as a separate element
                        let used_type_element_id = self.add_element_and_get_id(
                            CodeElementKind::UsedType,
                            field_type_str.clone(),
                            Some(struct_full_path.clone()),
                        );
                        self.elements.get_mut(used_type_element_id).unwrap().type_name = Some(field_type_str);
                    }
                }
                
                let struct_id = self.add_element_and_get_id(
                    CodeElementKind::Struct,
                    struct_name,
                    struct_parent_path,
                );
                let struct_info = self.elements.get_mut(struct_id).unwrap();
                struct_info.associated_idents = associated_idents;
                struct_info.related_types = related_types;
            }
            Item::Enum(item_enum) => {
                let enum_name = item_enum.ident.to_string();
                let enum_full_path = self.get_full_path(&enum_name);
                let enum_parent_path = parent_path.clone();

                let mut enum_associated_idents: Vec<String> = Vec::new();

                for variant in &item_enum.variants {
                    let variant_name = variant.ident.to_string();
                    enum_associated_idents.push(variant_name.clone());

                    // Store variant's related types temporarily
                    let mut variant_related_types: Vec<String> = Vec::new();

                    // Add used types for variant's fields
                    match &variant.fields {
                        Fields::Named(fields_named) => {
                            for field in &fields_named.named {
                                let field_type_str = Self::get_type_string(&field.ty);
                                variant_related_types.push(field_type_str.clone());
                                // Add used type as a separate element
                                let used_type_element_id = self.add_element_and_get_id(
                                    CodeElementKind::UsedType,
                                    field_type_str.clone(),
                                    Some(format!("{}::{}", enum_full_path, variant_name)), // Correct parent path for UsedType inside variant
                                );
                                self.elements.get_mut(used_type_element_id).unwrap().type_name = Some(field_type_str);
                            }
                        }
                        Fields::Unnamed(fields_unnamed) => {
                            for field in &fields_unnamed.unnamed {
                                let field_type_str = Self::get_type_string(&field.ty);
                                variant_related_types.push(field_type_str.clone());
                                // Add used type as a separate element
                                let used_type_element_id = self.add_element_and_get_id(
                                    CodeElementKind::UsedType,
                                    field_type_str.clone(),
                                    Some(format!("{}::{}", enum_full_path, variant_name)), // Correct parent path for UsedType inside variant
                                );
                                self.elements.get_mut(used_type_element_id).unwrap().type_name = Some(field_type_str);
                            }
                        }
                        Fields::Unit => {}
                    }
                    // Add variant element itself
                    let variant_element_id = self.add_element_and_get_id(
                        CodeElementKind::Variant,
                        variant_name,
                        Some(enum_full_path.clone()),
                    );
                    self.elements.get_mut(variant_element_id).unwrap().related_types = variant_related_types;
                }
                let enum_id = self.add_element_and_get_id(
                    CodeElementKind::Enum,
                    enum_name,
                    enum_parent_path,
                );
                let enum_info = self.elements.get_mut(enum_id).unwrap();
                enum_info.associated_idents = enum_associated_idents;
            }
            Item::Mod(item_mod) => {
                let _mod_id = self.add_element_and_get_id( // Renamed to _mod_id as it's not directly used
                    CodeElementKind::Module,
                    item_mod.ident.to_string(),
                    parent_path.clone(),
                );
                self.push_path_segment(&item_mod.ident.to_string());
                if let Some((_, items)) = &item_mod.content {
                    for item in items {
                        self.visit_item(&item);
                    }
                }
                self.pop_path_segment();
            }
            Item::Const(item_const) => {
                let const_name = item_const.ident.to_string();
                let _const_full_path = self.get_full_path(&const_name); // Prefixed with _
                let const_parent_path = parent_path.clone();

                let type_str = Self::get_type_string(&item_const.ty);
                
                let const_id = self.add_element_and_get_id(
                    CodeElementKind::Const,
                    const_name,
                    const_parent_path,
                );
                self.elements.get_mut(const_id).unwrap().type_name = Some(type_str.clone());

                // Add used type as a separate element
                let used_type_element_id = self.add_element_and_get_id(
                    CodeElementKind::UsedType,
                    type_str.clone(),
                    Some(self.elements.get(const_id).unwrap().full_path.clone()),
                );
                self.elements.get_mut(used_type_element_id).unwrap().type_name = Some(type_str);
            }
            Item::Static(item_static) => {
                let static_name = item_static.ident.to_string();
                let _static_full_path = self.get_full_path(&static_name); // Prefixed with _
                let static_parent_path = parent_path.clone();

                let type_str = Self::get_type_string(&item_static.ty);
                
                let static_id = self.add_element_and_get_id(
                    CodeElementKind::Static,
                    static_name,
                    static_parent_path,
                );
                self.elements.get_mut(static_id).unwrap().type_name = Some(type_str.clone());

                // Add used type as a separate element
                let used_type_element_id = self.add_element_and_get_id(
                    CodeElementKind::UsedType,
                    type_str.clone(),
                    Some(self.elements.get(static_id).unwrap().full_path.clone()),
                );
                self.elements.get_mut(used_type_element_id).unwrap().type_name = Some(type_str);
            }
            Item::Impl(item_impl) => {
                // An Impl block itself isn't a named element in the same way, but its methods are.
                // We'll capture the self type and optionally the trait type to form a temporary path
                let self_ty_str = Self::get_type_string(&item_impl.self_ty);
                let impl_path_segment = if let Some((_, path, _)) = &item_impl.trait_ {
                    format!("impl_{}_for_{}", path.to_token_stream().to_string().replace(" ", ""), self_ty_str)
                } else {
                    format!("impl_for_{}", self_ty_str)
                };

                self.push_path_segment(&impl_path_segment);
                for item in &item_impl.items {
                    let parent_path_for_impl_item = self.get_current_parent_path();
                    match item {
                        ImplItem::Fn(impl_fn) => {
                            let method_name = impl_fn.sig.ident.to_string();
                            let method_full_path = self.get_full_path(&method_name);
                            let method_parent_path = parent_path_for_impl_item.clone();

                            let mut associated_idents: Vec<String> = Vec::new();
                            let mut related_types: Vec<String> = Vec::new();

                            // Parameters and return types
                            for input in &impl_fn.sig.inputs {
                                if let syn::FnArg::Typed(pat_type) = input {
                                    let param_name = pat_type.pat.to_token_stream().to_string();
                                    let param_type_str = Self::get_type_string(&pat_type.ty);

                                    associated_idents.push(param_name.clone());
                                    related_types.push(param_type_str.clone());
                                    
                                    let param_element_id = self.add_element_and_get_id(
                                        CodeElementKind::Parameter,
                                        param_name,
                                        Some(method_full_path.clone()),
                                    );
                                    self.elements.get_mut(param_element_id).unwrap().type_name = Some(param_type_str.clone());
                                    
                                    let used_type_element_id = self.add_element_and_get_id(
                                        CodeElementKind::UsedType,
                                        param_type_str.clone(),
                                        Some(method_full_path.clone()),
                                    );
                                    self.elements.get_mut(used_type_element_id).unwrap().type_name = Some(param_type_str);
                                }
                            }
                            if let syn::ReturnType::Type(_, ty) = &impl_fn.sig.output {
                                let return_type_str = Self::get_type_string(ty);
                                related_types.push(return_type_str.clone());
                                
                                let return_element_id = self.add_element_and_get_id(
                                    CodeElementKind::ReturnType,
                                    return_type_str.clone(),
                                    Some(method_full_path.clone()),
                                );
                                self.elements.get_mut(return_element_id).unwrap().type_name = Some(return_type_str.clone());
                                
                                let used_type_element_id = self.add_element_and_get_id(
                                    CodeElementKind::UsedType,
                                    return_type_str.clone(),
                                    Some(method_full_path.clone()),
                                );
                                self.elements.get_mut(used_type_element_id).unwrap().type_name = Some(return_type_str);
                            }

                            let method_id = self.add_element_and_get_id(
                                CodeElementKind::Method,
                                method_name,
                                method_parent_path,
                            );
                            let method_info = self.elements.get_mut(method_id).unwrap();
                            method_info.associated_idents = associated_idents;
                            method_info.related_types = related_types;
                        }
                        ImplItem::Const(impl_const) => {
                            let const_name = impl_const.ident.to_string();
                            let _const_full_path = self.get_full_path(&const_name); // Prefix with _
                            let const_parent_path = parent_path_for_impl_item.clone();

                            let type_str = Self::get_type_string(&impl_const.ty);

                            let const_id = self.add_element_and_get_id(
                                CodeElementKind::Const,
                                const_name,
                                const_parent_path,
                            );
                            self.elements.get_mut(const_id).unwrap().type_name = Some(type_str.clone());

                            let used_type_element_id = self.add_element_and_get_id(
                                CodeElementKind::UsedType,
                                type_str.clone(),
                                Some(self.elements.get(const_id).unwrap().full_path.clone()),
                            );
                            self.elements.get_mut(used_type_element_id).unwrap().type_name = Some(type_str);
                        }
                        ImplItem::Type(impl_type) => {
                            let type_name = impl_type.ident.to_string();
                            let _type_full_path = self.get_full_path(&type_name); // Prefix with _
                            let type_parent_path = parent_path_for_impl_item.clone();
                            let type_str = Self::get_type_string(&impl_type.ty);
                            
                            // Associated type element
                            let associated_type_id = self.add_element_and_get_id(
                                CodeElementKind::UsedType, // Represents the associated type declaration itself
                                type_name,
                                type_parent_path,
                            );
                            self.elements.get_mut(associated_type_id).unwrap().type_name = Some(type_str.clone());

                            // Add the type it's associated *with* as another UsedType
                            let used_type_element_id = self.add_element_and_get_id(
                                CodeElementKind::UsedType,
                                type_str.clone(),
                                Some(self.elements.get(associated_type_id).unwrap().full_path.clone()),
                            );
                            self.elements.get_mut(used_type_element_id).unwrap().type_name = Some(type_str);
                        }
                        _ => {}
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


/// Collects code elements from all Rust files within a given directory.
pub fn collect_code_elements_from_dir(path: &Path) -> Vec<CodeElementInfo> {
    let mut collector = CodeElementCollector::new();

    let crate_name = path.file_name().and_then(|s| s.to_str()).unwrap_or("crate").to_string();
    // Add crate root as the first element
    let _crate_root_id = collector.add_element_and_get_id(CodeElementKind::Crate, crate_name.clone(), None); // Renamed to _crate_root_id as it's not directly used
    collector.push_path_segment(&crate_name);


    for entry in WalkDir::new(path)
        .into_iter()
        .filter_map(|e| e.ok())
        .filter(|e| e.file_type().is_file() && e.path().extension().map_or(false, |ext| ext == "rs"))
    {
        let file_path = entry.path();
        let file_content = std::fs::read_to_string(file_path).unwrap_or_default();

        let ast = syn::parse_file(&file_content).expect("Failed to parse Rust file");

        // Save current path length to correctly pop segments added for this file
        let current_path_len_before_file = collector.current_path_segments.len();

        if let Some(relative_path) = file_path.strip_prefix(path).ok() {
            let module_path_segments: Vec<String> = relative_path
                .parent() // Get directory relative to crate root
                .unwrap_or(Path::new(""))
                .iter()
                .filter_map(|s| s.to_str().map(|s_str| s_str.to_string()))
                .collect();

            // Handle `lib.rs` and `main.rs` as root modules
            if relative_path.file_name().map_or(false, |f| f == "lib.rs" || f == "main.rs") {
                // No additional module segment from filename for lib.rs/main.rs
                for segment in module_path_segments {
                    collector.push_path_segment(&segment);
                }
            } else if let Some(file_stem) = relative_path.file_stem().and_then(|s| s.to_str()) {
                for segment in module_path_segments {
                    collector.push_path_segment(&segment);
                }
                collector.push_path_segment(file_stem);
            }
        }

        for item in ast.items {
            collector.visit_item(&item);
        }

        // Pop path segments added for this file
        while collector.current_path_segments.len() > current_path_len_before_file {
            collector.pop_path_segment();
        }
    }
    collector.elements
}