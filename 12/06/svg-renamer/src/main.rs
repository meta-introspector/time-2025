
use std::fs;
use std::hash::{Hash, Hasher}; // Keep Hash and Hasher for truncate_with_hash
use roxmltree::{Document, Node as RoxmlNode}; // Alias roxmltree::Node to RoxmlNode
use xmlwriter::{XmlWriter, Options, Indent}; // Import Options and Indent explicitly
use std::io; // Import io (needed for Box<dyn std::error::Error>)
use config_lib;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let (config, _) = config_lib::find_and_read_config("lean_introspector/config.toml").map_err(|e| {
        eprintln!("Failed to read config file: {}", e);
        io::Error::new(io::ErrorKind::NotFound, e)
    })?;

    let input = &config.input_file;
    let output = input.with_extension("renamed.svg");
    let max_length = None;

    let svg_data = fs::read_to_string(&input)?;
    let doc = Document::parse(&svg_data)?;

    let mut writer = XmlWriter::new(Options {
            attributes_indent: Indent::None,
            ..Default::default()
        });

    // Start processing from the document's root element
    if let Some(root_element) = doc.root().children().find(|n| n.is_element()) {
        process_roxml_node(&root_element, &mut writer, max_length)?;
    } else {
        return Err("SVG document has no root element.".into());
    }

    let modified_svg = writer.into_string(); // Get the XML string

    if let Some(parent) = output.parent() {
        fs::create_dir_all(parent)?;
    }
    fs::write(&output, modified_svg)?; // fs::write returns Result

    println!("Renamed groups and wrote to {}", output.display());
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


