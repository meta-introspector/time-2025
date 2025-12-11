use heck::ToUpperCamelCase;
use quote::{format_ident, quote};
use serde_json::Value;
use std::collections::{BTreeMap, BTreeSet};
use std::env;
use std::fs;
use std::io;
use syn::parse_str;
use config_lib;

type AstMap = BTreeMap<String, BTreeSet<String>>;

fn main() -> io::Result<()> {
    let args: Vec<String> = env::args().collect();
    if args.len() != 2 {
        eprintln!("Usage: {} <output_rust_path>", args[0]);
        std::process::exit(1);
    }

    let output_path_str = &args[1];

    let (config, _) = config_lib::find_and_read_config("lean_introspector/config.toml").map_err(|e| {
        eprintln!("Failed to read config file: {}", e);
        io::Error::new(io::ErrorKind::NotFound, e)
    })?;

    let full_dataset_path = &config.dataset_path;
    println!("Resolved dataset path: {}", full_dataset_path.display());

    match fs::metadata(&full_dataset_path) {
        Ok(metadata) => {
            if !metadata.is_dir() {
                eprintln!("Error: Dataset path '{}' is not a directory.", full_dataset_path.display());
                std::process::exit(1);
            }
        }
        Err(e) => {
            eprintln!("Error: Could not read dataset path '{}'.", full_dataset_path.display());
            eprintln!("Reason: {}", e);
            std::process::exit(1);
        }
    }

    let mut ast_map = AstMap::new();

    for entry in fs::read_dir(&full_dataset_path)? {
        let entry = entry?;
        let path = entry.path();
        if path.is_file() && path.extension().map_or(false, |ext| ext == "json") {
            let content = fs::read_to_string(&path)?;
            let json: Value = serde_json::from_str(&content).expect(&format!("Failed to parse JSON from {:?}", path));
            infer_ast_structure(&json, &mut ast_map);
        }
    }
    println!("Finished processing all JSON files.");

    let rust_code = generate_rust_code(&ast_map);
    let formatted_code = pretty_print_rust_code(&rust_code.to_string());
    
    fs::write(output_path_str, formatted_code)?;
    println!("Successfully generated Rust HIR model at {}", output_path_str);

    Ok(())
}

// ... (rest of the functions are the same as before)
fn infer_ast_structure(value: &Value, ast_map: &mut AstMap) {
    match value {
        Value::Object(map) => {
            if let Some(Value::String(kind)) = map.get("kind") {
                let entry = ast_map.entry(kind.clone()).or_default();
                for key in map.keys() {
                    if key != "kind" {
                        entry.insert(key.clone());
                    }
                }
            }
            for (key, val) in map.iter() {
                if let Value::Object(inner_map) = val {
                    if inner_map.get("kind").is_none() {
                        let entry = ast_map.entry(key.clone()).or_default();
                        for inner_key in inner_map.keys() {
                            entry.insert(inner_key.clone());
                        }
                    }
                }
                infer_ast_structure(val, ast_map);
            }
        }
        Value::Array(arr) => {
            for val in arr {
                infer_ast_structure(val, ast_map);
            }
        }
        _ => {}
    }
}

fn generate_rust_code(ast_map: &AstMap) -> proc_macro2::TokenStream {
    let mut struct_defs = Vec::new();
    let mut enum_variants = Vec::new();
    let root_enum_name = format_ident!("Expr");

    let mut main_variants = BTreeMap::new();
    let mut other_structs = BTreeMap::new();

    for (name, fields) in ast_map {
        if name.contains('.') || *name == "AsyncConstB" || *name == "AsyncConstantInfo" || *name == "AsyncConstantInfo2" || *name == "Check" || *name == "ConstantInfo" || *name == "BinderInfo" {
            main_variants.insert(name.clone(), fields.clone());
        } else {
            other_structs.insert(name.clone(), fields.clone());
        }
    }
    
    let all_struct_names: BTreeSet<String> = other_structs.keys().cloned().collect();
    let all_main_variant_names: BTreeSet<String> = main_variants.keys().cloned().collect();

    for (name, fields) in &other_structs {
        let struct_name_pascal = name.to_upper_camel_case();
        let struct_name = format_ident!("{}", struct_name_pascal);
        let mut struct_fields = Vec::new();

        for field in fields.iter() {
            let field_name_snake = format_ident!("{}", sanitize_field_name(field));
            let mut type_str = infer_type_name(field, &all_struct_names, &all_main_variant_names);

            if type_str == struct_name_pascal {
                type_str = format!("Box<{}>", type_str);
            }
            if all_struct_names.contains(field) {
                type_str = field.to_upper_camel_case();
            }
            else if all_main_variant_names.contains(field) {
                type_str = "Box<Expr>".to_string();
            }

            let field_type: syn::Type = parse_str(&type_str).expect(&format!("Failed to parse type string: {}", type_str));

            struct_fields.push(quote! {
                #[serde(rename = #field)]
                #[serde(skip_serializing_if = "Option::is_none")]
                pub #field_name_snake: Option<#field_type>
            });
        }
        struct_defs.push(quote! {
            #[derive(Debug, Clone, PartialEq, serde::Serialize, serde::Deserialize)]
            pub struct #struct_name {
                #(#struct_fields),*
            }
        });
    }

    for (kind, fields) in &main_variants {
        let struct_name_pascal = kind.replace("Lean.", "").replace(".", "").to_upper_camel_case();
        let struct_name = format_ident!("{}", struct_name_pascal);
        let enum_variant_name = format_ident!("{}", struct_name_pascal);

        let mut struct_fields = Vec::new();
        for field in fields.iter() {
            let field_name_snake = format_ident!("{}", sanitize_field_name(field));
            let mut type_str = infer_type_name(field, &all_struct_names, &all_main_variant_names);

            if type_str == struct_name_pascal {
                type_str = format!("Box<{}>", type_str);
            }
            if all_struct_names.contains(field) {
                type_str = field.to_upper_camel_case();
            }
            else if all_main_variant_names.contains(field) {
                type_str = "Box<Expr>".to_string();
            }
            
            let field_type: syn::Type = parse_str(&type_str).expect(&format!("Failed to parse type string: {}", type_str));

            struct_fields.push(quote! {
                #[serde(rename = #field)]
                #[serde(skip_serializing_if = "Option::is_none")]
                pub #field_name_snake: Option<#field_type>
            });
        }
        
        struct_defs.push(quote! {
            #[derive(Debug, Clone, PartialEq, serde::Serialize, serde::Deserialize)]
            pub struct #struct_name {
                #(#struct_fields),*
            }
        });

        enum_variants.push(quote! {
            #[serde(rename = #kind)]
            #enum_variant_name(#struct_name)
        });
    }

    quote! {
        use serde::{self, Serialize, Deserialize};

        #(#struct_defs)*

        #[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
        #[serde(untagged)]
        pub enum #root_enum_name {
            #(#enum_variants),*
        }

        pub type Level = serde_json::Value;
    }
}

fn infer_type_name(field_name: &str, other_struct_names: &BTreeSet<String>, all_main_variant_names: &BTreeSet<String>) -> String {
    let camel_case_name = field_name.to_upper_camel_case();

    if other_struct_names.contains(field_name) {
        return camel_case_name;
    }
    if all_main_variant_names.contains(field_name) {
        return "Box<Expr>".to_string();
    }
    
    match field_name {
        "fn" | "arg" | "lambdB" | "forbdB" | "forbndrTyp" | "lambndrTp" | "rhs" | "cnstInf" => "Box<Expr>".to_string(),
        "levels" | "levelParams" | "all" => "Vec<Level>".to_string(),
        "Rules" => "Vec<Expr>".to_string(),
        "name" | "declName" | "value" | "binderName" | "binderInfo" => "String".to_string(),
        "numIndices" | "numParams" | "numMinors" | "numMotives" | "nfields" => "i64".to_string(),
        "isUnsafe" | "k" => "bool".to_string(),
        "type" => "String".to_string(),
        _ => "serde_json::Value".to_string(),
    }
}

fn sanitize_field_name(name: &str) -> String {
    let snake_name = name.to_upper_camel_case().to_lowercase();
    if snake_name == "fn" || snake_name == "type" {
        format!("r#{}", snake_name)
    } else {
        snake_name
    }
}

fn pretty_print_rust_code(code: &str) -> String {
    let syn_tree = syn::parse_file(code).expect("Failed to parse generated code");
    prettyplease::unparse(&syn_tree)
}
