use std::path::PathBuf;
use usvg::{Tree, Node, Group, WriteOptions};
use xmlwriter::XmlWriter;
use std::hash::{Hash, Hasher};

struct Args {
    input: PathBuf,
    output: PathBuf,
    max_length: Option<usize>,
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let args = parse_args();

    // Load font database (required for text processing)
    let mut fontdb = fontdb::Database::new();
    fontdb.load_system_fonts();

    // Parse SVG
    let tree = Tree::from_file(&args.input, &usvg::Options::default(), &fontdb)?;

    // Process tree to rename groups
    let processed_tree = rename_groups_with_text(&tree, args.max_length);

    // Write modified SVG
    // The original snippet used `processed_tree.write(&mut xml, &WriteOptions::default())?`, 
    // which is not standard in usvg 0.14.0. 
    // Assuming the intent is to get the SVG XML string and write it to a file.
    let svg_string = processed_tree.to_string(&WriteOptions::default());
    std::fs::write(&args.output, svg_string)?;


    println!("Renamed groups and wrote to {}", args.output.display());
    Ok(())
}

fn rename_groups_with_text(tree: &Tree, max_length: Option<usize>) -> Tree {
    // Clone the tree for modification
    let mut new_tree = tree.clone();

    // Process root group recursively
    process_group(&mut new_tree.root, max_length);

    new_tree
}

fn process_group(group: &mut Group, max_length: Option<usize>) {
    // Collect children that are groups to process them recursively
    let mut groups_to_process = Vec::new();
    for child_node in &mut group.children {
        if let Node::Group(g) = child_node {
            groups_to_process.push(g);
        }
    }

    for g in groups_to_process {
        // Check if group contains text
        if let Some(text_content) = extract_text_from_group(g) {
            let escaped = escape_text(&text_content);
            let processed = if let Some(max_len) = max_length {
                truncate_with_hash(&escaped, max_len)
            } else {
                escaped
            };

            // Update group ID
            g.id = processed;
        }

        // Recursively process nested groups
        process_group(g, max_length);
    }
}


fn extract_text_from_group(group: &Group) -> Option<String> {
    let mut text_parts = Vec::new();

    for child in &group.children {
        if let Node::Text(text) = child {
            // Extract text content from text node
            for chunk in &text.chunks {
                for span in &chunk.spans {
                    text_parts.push(&chunk.text[span.start..span.end]);
                }
            }
        }
    }

    if text_parts.is_empty() {
        None
    } else {
        Some(text_parts.join(" "))
    }
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

    use std::hash::{Hash, Hasher};
    let mut hasher = std::collections::hash_map::DefaultHasher::new();
    text.hash(&mut hasher);
    let hash = hasher.finish();

    // Use char_indices to correctly truncate based on characters, not bytes.
    let truncate_char_len = max_len.saturating_sub(9); // Reserve space for "_hash123"
    let truncated_text: String = text.char_indices()
        .take_while(|(i, _)| *i < truncate_char_len)
        .map(|(_, c)| c)
        .collect();

    format!("{}_{:x}", truncated_text, hash)
}

fn parse_args() -> Args {
    // Simple argument parsing
    let mut args = std::env::args().skip(1);
    let input = PathBuf::from(args.next().expect("Missing input file"));
    let output = PathBuf::from(args.next().expect("Missing output file"));
    let max_length = args.next().and_then(|s| s.parse().ok());

    Args { input, output, max_length }
}