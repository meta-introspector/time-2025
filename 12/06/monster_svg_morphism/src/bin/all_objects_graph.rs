use monster_svg_morphism::code_parser::{collect_code_elements_from_dir, CodeElementInfo}; // Removed CodeElementKind
use std::path::Path;
use std::collections::HashMap;
use std::fs::File;
use std::io::Write;
use petgraph::Graph;
use petgraph::dot::{Dot, Config}; // Only import Dot and Config
use petgraph::visit::{NodeRef, EdgeRef}; // Import NodeRef and EdgeRef


#[derive(Debug, Clone, PartialEq, Eq)]
pub enum RelationType {
    Defines,        // Parent defines child (e.g., Module defines Function, Struct defines Field)
    UsesType,       // An element uses another element as a type (e.g., Field uses Struct, Fn parameter uses Type)
    ContainsField,  // Struct contains a field
    ContainsVariant, // Enum contains a variant
    HasParameter,   // Function has a parameter
    HasReturnType,  // Function has a return type
    // Implements,     // A type implements a trait (more complex to extract with current parser)
    // Calls,          // Function calls another function (requires body parsing)
}

// Removed CustomNodeConfig struct and its impl Labeller for CustomNodeConfig block
// as it's replaced by Dot::with_attr_getters


fn main() {
    println!("Building comprehensive code graph...");

    let crate_path = Path::new(".").canonicalize().expect("Failed to canonicalize path");
    let elements = collect_code_elements_from_dir(&crate_path);

    if elements.is_empty() {
        println!("No code elements found in the crate. Exiting.");
        return;
    }

    let mut graph = Graph::<CodeElementInfo, RelationType>::new();
    let mut full_path_to_node_index = HashMap::new();
    // let mut id_to_node_index = HashMap::new(); // Not strictly needed for graph building, but useful for lookup

    // Add nodes to the graph
    for element in &elements {
        let node_idx = graph.add_node(element.clone());
        full_path_to_node_index.insert(element.full_path.clone(), node_idx);
        // id_to_node_index.insert(element.id, node_idx);
    }

    // Add edges to the graph
    for element in &elements {
        let source_idx = *full_path_to_node_index.get(&element.full_path).unwrap();

        // 1. Defines relationships (parent to child)
        if let Some(parent_path) = &element.parent_full_path {
            if let Some(&parent_idx) = full_path_to_node_index.get(parent_path) {
                graph.add_edge(parent_idx, source_idx, RelationType::Defines);
            }
        }

        // 2. UsesType relationships
        if let Some(type_name) = &element.type_name {
            // Find if this type_name corresponds to another CodeElementInfo by its full_path
            if let Some(&target_idx) = full_path_to_node_index.get(type_name) {
                 graph.add_edge(source_idx, target_idx, RelationType::UsesType);
            } else {
                 // Try to resolve by simple name if full_path match fails
                 // This is a heuristic and can be inaccurate, e.g., for "Option<String>" it would look for "String"
                 for (other_full_path, &other_idx) in &full_path_to_node_index {
                     if other_full_path.ends_with(&format!("::{}", type_name)) || other_full_path.as_str() == type_name.as_str() { // Corrected comparison
                         graph.add_edge(source_idx, other_idx, RelationType::UsesType);
                         break;
                     }
                 }
            }
        }
    }


    // Generate DOT file
    let dot_file_path = "all_objects_graph.dot";
    let svg_file_path = "all_objects_graph.svg";
    let mut file = File::create(dot_file_path).expect("Failed to create .dot file");

    // Use Dot::with_attr_getters for custom node and edge labels
    write!(file, "{:?}", Dot::with_attr_getters(
        &graph,
        &[Config::NodeNoLabel], // Use NodeNoLabel to ensure our custom label getter is used
        &|_, edge_ref| format!("label = \"{:?}\"", edge_ref.weight()), // Edge label getter
        &|_, node_ref| format!("label = \"{}::{}\\n({:?})\"",
            node_ref.weight().parent_full_path.as_deref().unwrap_or(""),
            node_ref.weight().name,
            node_ref.weight().kind
        ) // Node label getter
    )).expect("Failed to write dot graph");


    println!("\nGenerated Graphviz DOT file: {}", dot_file_path);
    println!("Attempting to render SVG using Graphviz 'dot' command...");
    println!("NOTE: Graphviz (dot command) must be installed and in your PATH for SVG generation to work.");

    println!("\nTo generate SVG, run: dot -Tsvg {} -o {}", dot_file_path, svg_file_path);
    println!("Graph SVG output attempted to be generated at: {}", svg_file_path);
}
