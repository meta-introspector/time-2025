use std::path::PathBuf;
use usvg::{Tree, Options as UsvgOptions, Node};
use encoding_rs::{Encoding, UTF_16LE, UTF_8};
use std::borrow::Cow;

use crate::processors::file_entry::FileEntry;
use crate::processors::extracted_data::ExtractedData;
use crate::processors::traverse_usvg_node::traverse_usvg_node;


/// Processes an SVG file, extracts terms and relationships, and merges them into ExtractedData.
pub fn process_svg_file(file_entry: &FileEntry, extracted_data: &mut ExtractedData) -> Result<(), Box<dyn std::error::Error>> {
    let (encoding, _had_bom) = Encoding::for_bom(&file_entry.content).unzip();
    let encoding = encoding.unwrap_or(UTF_8); // Default to UTF-8 if no BOM

    let (cow, _, _) = encoding.decode(&file_entry.content);
    let svg_str = cow.into_owned();
    
    let usvg_options = UsvgOptions::default();
    let rtree = Tree::from_str(&svg_str, &usvg_options)?;

    // Start traversal from the root group
    // The `rtree.root()` method returns a `&Group`. We need to convert this to a `Node::Group`
    // to start the `traverse_usvg_node` function, which expects a `&Node`.
    // We clone the Group and box it into a Node::Group.
    traverse_usvg_node(&Node::Group(Box::new(rtree.root().clone())), file_entry, extracted_data, None);

    Ok(())
}
