use std::path::PathBuf;
use std::fs;
use std::hash::{Hash, Hasher}; // Keep Hash and Hasher for truncate_with_hash
use roxmltree::{Document, Node as RoxmlNode}; // Alias roxmltree::Node to RoxmlNode
use xmlwriter::{XmlWriter, Indent, Options}; // Import Options explicitly
use std::io; // Import io (needed for Box<dyn std::error::Error>)

struct Args {
    input: PathBuf,
    output: PathBuf,
    max_length: Option<usize>,
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let args = parse_args();

    let svg_data = fs::read_to_string(&args.input)?;
    let doc = Document::parse(&svg_data)?;

    let mut output_buffer = Vec::new(); // Create an in-memory buffer
    let mut writer = XmlWriter::new( // Correct initialization
        &mut output_buffer, // Pass a mutable reference to the buffer
        Options {
            attributes_indent: Indent::None,
            ..Default::default()
        }
    );

    // Start processing from the document's root element
    if let Some(root_element) = doc.root().children().find(|n| n.is_element()) {
        process_roxml_node(&root_element, &mut writer, args.max_length)?; // Now returns Result and uses ?
    } else {
        return Err("SVG document has no root element.".into());
    }

    let modified_svg = String::from_utf8(output_buffer)?; // Convert to String

    if let Some(parent) = args.output.parent() {
        fs::create_dir_all(parent)?;
    }
    fs::write(&args.output, modified_svg)?; // fs::write returns Result

    println!("Renamed groups and wrote to {}", args.output.display());
    Ok(())
}

fn process_roxml_node<'a, W: io::Write>(node: &RoxmlNode<'a, 'a>, writer: &mut XmlWriter<'a, W>, max_length: Option<usize>) -> io::Result<()> {
    if node.is_element() {
        writer.start_element(node.tag_name().name())?;

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
                writer.write_attribute("id", &processed_id)?;
                current_id = Some(processed_id);
            }
        }
        
        for attr in node.attributes() {
            if attr.name() == "id" {
                if current_id.is_none() {
                    writer.write_attribute(attr.name(), attr.value())?;
                }
            } else {
                writer.write_attribute(attr.name(), attr.value())?;
            }
        }

        for child in node.children() {
            process_roxml_node(&child, writer, max_length)?;
        }

        writer.end_element()?;
    } else if node.is_text() {
        writer.write_text(node.text().unwrap_or_default())?;
    } else if node.is_comment() {
        // Optionally handle comments
    }
    Ok(())
}

fn collect_text_from_children(node: &RoxmlNode) -> String {
    let mut text_parts = Vec::new();
    for child in node.descendants().filter(|n| n.is_text()) {
        if let Some(text_content) = child.text() {
            text_parts.push(text_content.trim().to_string());
        }
    }
    text_parts.join(" ")
}

fn escape_text(text: &str) -> String {
    text.chars()
        .map(|c| match c {
            '&' => "&amp;".to_string(),
            '<' => "&lt;".to_string(),
            '>' => "&gt;".to_string(),
            '"' => "&quot;".to_string(),
            '\'' => "&apos;".to_string(),
            ' ' => "_".to_string(),
            _ if !c.is_ascii_alphanumeric() => format!("_{:x}_", c as u32),
            _ => c.to_string(),
        })
        .collect()
}

fn truncate_with_hash(text: &str, max_len: usize) -> String {
    if text.len() <= max_len {
        return text.to_string();
    }

    let mut hasher = std::collections::hash_map::DefaultHasher::new();
    text.hash(&mut hasher);
    let hash = hasher.finish();

    let truncate_char_len = max_len.saturating_sub(9);
    let truncated_text: String = text.char_indices()
        .take_while(|(i, _)| *i < truncate_char_len)
        .map(|(_, c)| c)
        .collect();

    format!("{}_{:x}", truncated_text, hash)
}

fn parse_args() -> Args {
    let mut args = std::env::args().skip(1);
    let input = PathBuf::from(args.next().expect("Missing input file"));
    let output = PathBuf::from(args.next().expect("Missing output file"));
    let max_length = args.next().and_then(|s| s.parse().ok());

    Args { input, output, max_length }
}
