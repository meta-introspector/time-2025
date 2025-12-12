use std::fs;
use std::collections::{BTreeSet, BTreeMap};
use std::path::PathBuf;
use roxmltree::{Document, Node};
use serde::Serialize;

#[derive(Serialize)]
struct SemanticDictionaryTemplate {
    semantic_dictionary: BTreeMap<String, String>,
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let mut args = pico_args::Arguments::from_env();

    let input_svg_path: PathBuf = args.value_from_os_str("--input", parse_path)
        .map_err(|_| "Missing --input <SVG_FILE_PATH>")?;
    let output_toml_path: PathBuf = args.value_from_os_str("--output", parse_path)
        .map_err(|_| "Missing --output <TOML_FILE_PATH>")?;

    let svg_data = fs::read_to_string(&input_svg_path)?;
    let doc = Document::parse(&svg_data)?;

    let mut unique_text_snippets = BTreeSet::new();

    collect_text_nodes(&doc.root(), &mut unique_text_snippets);

    let mut semantic_dictionary = BTreeMap::new();
    for snippet in unique_text_snippets {
        semantic_dictionary.insert(snippet, "TO_BE_FILLED".to_string());
    }

    let template = SemanticDictionaryTemplate {
        semantic_dictionary,
    };

    let toml_content = toml::to_string_pretty(&template)?;

    if let Some(parent) = output_toml_path.parent() {
        fs::create_dir_all(parent)?;
    }
    fs::write(&output_toml_path, toml_content)?;

    println!("Semantic dictionary template written to {}", output_toml_path.display());

    Ok(())
}

fn collect_text_nodes(node: &Node, unique_text_snippets: &mut BTreeSet<String>) {
    if node.is_text() {
        let text = node.text().unwrap_or("").trim();
        if !text.is_empty() {
            unique_text_snippets.insert(text.to_string());
        }
    }

    for child in node.children() {
        collect_text_nodes(&child, unique_text_snippets);
    }
}

fn parse_path(s: &std::ffi::OsStr) -> Result<PathBuf, &'static str> {
    Ok(s.into())
}