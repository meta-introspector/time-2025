use std::path::PathBuf;
use usvg::{Node};

use crate::processors::file_entry::FileEntry;
use crate::processors::extracted_data::ExtractedData;
use crate::processors::term::{Term, TermType};
use crate::processors::relationship::{Relationship, RelationshipType};


/// Recursively processes a usvg::Node and its children.
pub fn traverse_usvg_node(node: &Node, file_entry: &FileEntry, extracted_data: &mut ExtractedData, parent_id: Option<&str>) {
    // Extract ID if available
    let current_node_id = if !node.id().is_empty() {
        Some(node.id().to_string())
    } else {
        None
    };

    if let Some(ref term_name) = current_node_id {
        extracted_data.add_term(Term {
            name: term_name.clone(),
            source_file: file_entry.path.clone(),
            term_type: TermType::SvgElement,
            prime_vector: None, // TODO: Assign PrimeVector
            frequency: 1,
        });

        // Add hierarchical relationship
        if let Some(p_id) = parent_id {
            extracted_data.add_relationship(Relationship {
                source_term_name: p_id.to_string(),
                target_term_name: term_name.clone(),
                rel_type: RelationshipType::SvgHierarchy,
                prime_vector: None, // TODO: Assign PrimeVector
            });
        }
    }

    match node {
        Node::Text(text_node) => {
            for chunk in text_node.chunks() {
                if !chunk.text().trim().is_empty() {
                    let content = chunk.text().to_string();
                    extracted_data.add_term(Term {
                        name: content.clone(),
                        source_file: file_entry.path.clone(),
                        term_type: TermType::SvgText,
                        prime_vector: None, // TODO: Assign PrimeVector
                        frequency: 1,
                    });

                    // Link text to its parent element if ID exists
                    if let Some(p_id) = parent_id {
                        extracted_data.add_relationship(Relationship {
                            source_term_name: p_id.to_string(),
                            target_term_name: content.to_string(),
                            rel_type: RelationshipType::SvgHierarchy, // or SvgContains
                            prime_vector: None,
                        });
                    }
                }
            }
        },
        Node::Group(group) => {
            let p_id = current_node_id.as_deref().or(parent_id);
            for child_node in group.children() {
                traverse_usvg_node(child_node, file_entry, extracted_data, p_id);
            }
        },
        Node::Path(_path) => {
            // TODO: Extract path data attributes if needed
        },
        Node::Image(_image) => {
            // TODO: Extract image references if needed
        },
    }
}
