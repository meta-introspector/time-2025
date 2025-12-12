use std::fs;
use std::hash::{Hash, Hasher};
use roxmltree::{Document, Node as RoxmlNode};
use xmlwriter::{XmlWriter, Options, Indent};
use std::io;
use serde::Deserialize;
use std::collections::hash_map::DefaultHasher;
use std::path::Path;

mod escape;
use escape::escape_text;

#[derive(Debug, Deserialize)]
struct SvgReaderConfig {
    input_file: String,
    output_file: String,
}

#[derive(Debug, Deserialize)]
struct AppConfig {
    svg_reader: SvgReaderConfig,
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let config_str = fs::read_to_string("lean_introspector/config.toml")?;
    let app_config: AppConfig = toml::from_str(&config_str)?;

    let input_path = Path::new(&app_config.svg_reader.input_file);
    let output_path = Path::new(&app_config.svg_reader.output_file);
    let max_length = None;

    let svg_data = fs::read_to_string(&input_path)?;
    let doc = Document::parse(&svg_data)?;

    let mut writer = XmlWriter::new(Options {
            attributes_indent: Indent::None,
            ..Default::default()
        });

    if let Some(root_element) = doc.root().children().find(|n| n.is_element()) {
        process_roxml_node(&root_element, &mut writer, max_length)?;
    } else {
        return Err("SVG document has no root element.".into());
    }

    let modified_svg = writer.into_string();

    if let Some(parent) = output_path.parent() {
        fs::create_dir_all(parent)?;
    }
    fs::write(&output_path, modified_svg)?;

    println!("Renamed groups and wrote to {}", output_path.display());
    Ok(())
}

fn process_roxml_node(node: &RoxmlNode, writer: &mut XmlWriter, max_length: Option<usize>) -> io::Result<()> {
    if node.is_element() {
        writer.start_element(node.tag_name().name());

        let mut current_id: Option<String> = None;
        if node.tag_name().name() == "g" {
            let text_in_group = collect_text_from_children(node);

            if !text_in_group.is_empty() {
                let escaped = escape_text(&text_in_group);
                let processed_id = if let Some(max_len) = max_length {
                    truncate_with_hash(&escaped, max_len)
                } else {
                    escaped
                };
                writer.write_attribute("id", &processed_id);
                current_id = Some(processed_id);
            }
        }
        
        for attr in node.attributes() {
            if attr.name() == "id" {
                if current_id.is_none() {
                    writer.write_attribute(attr.name(), attr.value());
                }
            } else {
                writer.write_attribute(attr.name(), attr.value());
            }
        }

        for child in node.children() {
            process_roxml_node(&child, writer, max_length)?;
        }

        writer.end_element();
    } else if node.is_text() {
        writer.write_text(node.text().unwrap_or_default());
    } else if node.is_comment() {
        // Optionally handle comments
    }
    Ok(())
}

fn collect_text_from_children(node: &RoxmlNode) -> String {
    let mut text = String::new();
    for child in node.children() {
        if child.is_text() {
            text.push_str(child.text().unwrap_or(""));
        }
        if child.is_element() {
            text.push_str(&collect_text_from_children(&child));
        }
    }
    text.split_whitespace().collect::<Vec<_>>().join(" ")
}

fn truncate_with_hash(s: &str, max_len: usize) -> String {
    if s.len() <= max_len {
        return s.to_string();
    }

    let mut hasher = DefaultHasher::new();
    s.hash(&mut hasher);
    let hash = hasher.finish();

    let truncated = &s[..max_len - 9]; // 8 for hash, 1 for underscore
    format!("{}_{:x}", truncated, hash)
}
