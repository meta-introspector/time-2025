use ndarray::{Array2};
use monster_svg_morphism::{code_parser::{collect_code_elements_from_dir, CodeElementKind}, types::prime_vector::PrimeMorphism};
use std::collections::{HashMap, BTreeSet};
use std::path::Path;
use std::fs::File; // Add File import
use std::io::Write; // Add Write import
use petgraph::Graph; // Add petgraph Graph import
use petgraph::stable_graph::NodeIndex; // For NodeIndex
use petgraph::dot::{Dot, Config}; // For Dot and Config


/// Prints a summary of the matrix, including sum, zero percentage, and an 80-character visual representation.
fn print_matrix_summary(matrix: &Array2<f64>, iteration: usize) {
    println!("\n--- Summary for Iteration {} (Matrix M^{}) ---", iteration, iteration);

    let total_sum = matrix.sum();
    println!("Total Sum: {:.2}", total_sum);

    let non_zero_count = matrix.iter().filter(|&x| x.abs() > f64::EPSILON).count();
    let total_cells = matrix.len();
    let zero_percentage = if total_cells > 0 {
        (1.0 - (non_zero_count as f64 / total_cells as f64)) * 100.0
    } else {
        0.0
    };
    println!("Zero Percentage: {:.2}%", zero_percentage);

    // 80-character visual summary
    let num_cols = matrix.ncols();
    let num_rows = matrix.nrows();
    
    if num_cols > 0 && num_rows > 0 {
        let mut summarized_values = Vec::with_capacity(80);
        let mut max_val = 0.0;

        for i in 0..80 {
            let start_col_idx = (i * num_cols) / 80;
            let end_col_idx = ((i + 1) * num_cols) / 80;
            
            // Ensure end_col_idx doesn't exceed num_cols (can happen if num_cols < 80)
            let end_col_idx = end_col_idx.min(num_cols);

            if start_col_idx >= end_col_idx {
                summarized_values.push(0.0);
                continue;
            }

            let mut section_sum = 0.0;
            let mut section_count = 0;

            for r in 0..num_rows {
                for c in start_col_idx..end_col_idx {
                    section_sum += matrix[(r, c)];
                    section_count += 1;
                }
            }
            let avg = if section_count > 0 { section_sum / section_count as f64 } else { 0.0 };
            summarized_values.push(avg);
            if avg > max_val {
                max_val = avg;
            }
        }

        print!("Visual (80 chars): ");
        if max_val > f64::EPSILON {
            let chars = " .:-=+*#%@"; // 10 intensity levels
            for &val in &summarized_values {
                let scaled_val = (val / max_val) * (chars.len() - 1) as f64;
                let char_idx = scaled_val.round() as usize;
                print!("{}", chars.chars().nth(char_idx).unwrap_or(' '));
            }
        } else {
            // All zeros or near zero
            print!("{}", "_".repeat(80));
        }
        println!();
    }
}


fn main() {
    println!("Starting analysis for building an Enum and Type relationship matrix.");

    let crate_path = Path::new(".").canonicalize().expect("Failed to canonicalize path");
    let declarations = collect_code_elements_from_dir(&crate_path);

    if declarations.is_empty() {
        println!("No declarations found in the crate. Exiting.");
        return;
    }

    // Filter for Structs and Enums
    let mut struct_enum_declarations = Vec::new();
    let mut unique_names = BTreeSet::new();

    for decl in declarations {
        if decl.kind == CodeElementKind::Struct || decl.kind == CodeElementKind::Enum {
            let simple_name = decl.full_path.split("::").last().unwrap_or("").to_string();
            if !simple_name.is_empty() {
                 unique_names.insert(simple_name.clone());
                 struct_enum_declarations.push(decl);
            }
        }
    }

    if struct_enum_declarations.is_empty() {
        println!("No structs or enums found to build the matrix. Exiting.");
        return;
    }

    let mut name_to_index: HashMap<String, usize> = HashMap::new();
    let mut index_to_name: Vec<String> = Vec::new();
    for (idx, name) in unique_names.iter().enumerate() {
        name_to_index.insert(name.clone(), idx);
        index_to_name.push(name.clone());
    }

    let matrix_dim = unique_names.len();
    let mut relationship_matrix = Array2::<f64>::zeros((matrix_dim, matrix_dim));
    let mut prime_morphism = PrimeMorphism::new(HashMap::new());


    println!("\nBuilding a {}x{} Enum and Type Relationship Matrix...", matrix_dim, matrix_dim);

    // Populate the matrix
    for decl in &struct_enum_declarations {
        let simple_decl_name = decl.full_path.split("::").last().unwrap_or("").to_string();
        if let Some(&row_idx) = name_to_index.get(&simple_decl_name) {
/*
            // If it's a struct, process its fields
            if decl.kind == CodeElementKind::Struct {
                for field_name in &decl.associated_idents {
                    // Get prime for the field name
                    let p_field = prime_morphism.get_prime_for_component(&field.name);
                    let weight_base = 1.0 / (p_field as f64);

                    // Try to resolve the field's type to another struct/enum
                    let simple_field_type_name = field.type_name.split("::").last().unwrap_or(&field.type_name).replace(">", "").to_string(); // Basic attempt to clean up generics

                    if let Some(&col_idx) = name_to_index.get(&simple_field_type_name) {
                        // M[struct_i][type_j] += weight_base
                        relationship_matrix[(row_idx, col_idx)] += weight_base;
                    }
                }
            } 
            // If it's an enum, process its variants (if they contain types)
            else if decl.kind == CodeElementKind::Enum {
                for variant_name in &decl.associated_idents {
                    for field_type_name in &variant.field_types {
                        // Get prime for the variant name (as proxy for connection)
                        let p_variant = prime_morphism.get_prime_for_component(&variant.name);
                        let weight_base = 1.0 / (p_variant as f64);

                        let simple_variant_type_name = field_type_name.split("::").last().unwrap_or(field_type_name).replace(">", "").to_string();
                        if let Some(&col_idx) = name_to_index.get(&simple_variant_type_name) {
                             relationship_matrix[(row_idx, col_idx)] += weight_base;
                        }
                    }
                }
            }
            */
        }
    }

    // Print the names corresponding to indices for clarity
    println!("\nMatrix Indices Mapping:");
    for (idx, name) in index_to_name.iter().enumerate() {
        println!("  {}: {}", idx, name);
    }

    // --- Graphviz DOT file generation ---
    let dot_file_path = "enum_type_graph.dot";
    let svg_file_path = "enum_type_graph.svg";
    
    // Create a petgraph Graph
    let mut graph = Graph::<String, f64>::new();
    let mut pg_node_indices = HashMap::new();

    // Add nodes to petgraph Graph
    for (idx, name) in index_to_name.iter().enumerate() {
        pg_node_indices.insert(name.clone(), graph.add_node(name.clone()));
    }

    // Add edges to petgraph Graph
    for i in 0..matrix_dim {
        for j in 0..matrix_dim {
            let weight = relationship_matrix[(i, j)];
            if weight.abs() > f64::EPSILON { // Check for non-zero weight
                let source_name = &index_to_name[i];
                let target_name = &index_to_name[j];
                let source_idx = *pg_node_indices.get(source_name).unwrap();
                let target_idx = *pg_node_indices.get(target_name).unwrap();
                graph.add_edge(source_idx, target_idx, weight);
            }
        }
    }

    // Write dot file using petgraph's Dot utility
    let mut file = File::create(dot_file_path).expect("Failed to create .dot file");
    write!(file, "{:?}", Dot::with_config(&graph, &[Config::EdgeNoLabel])).expect("Failed to write dot graph");


    println!("\nGenerated Graphviz DOT file: {}", dot_file_path);
    println!("Attempting to render SVG using Graphviz 'dot' command...");
    println!("NOTE: Graphviz (dot command) must be installed and in your PATH for SVG generation to work.");
    
    // Print M^1 summary
    print_matrix_summary(&relationship_matrix, 1);

    let mut current_matrix = relationship_matrix.clone(); // Start with M^1

    let num_iterations = 5;
    for i in 2..=num_iterations {
        current_matrix = current_matrix.dot(&relationship_matrix);
        print_matrix_summary(&current_matrix, i);
    }

    println!("\nIterative matrix multiplication complete for Enum and Type Relationship Matrix.");
    println!("Graph SVG output attempted to be generated at: {}", svg_file_path);
}
