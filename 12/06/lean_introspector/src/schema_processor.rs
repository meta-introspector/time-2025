// lean_introspector/src/schema_processor.rs
use serde_json::Value;

use crate::error::ThreadSafeError;
use crate::schema_inference::{Schema, SchemaNode};
use crate::prime_analysis::{PrimeVector, PrimeMorphism};
use crate::report::IterationReport;

// Helper function to traverse SchemaNode and generate PrimeVector
pub fn traverse_schema_node_for_prime_vector(
    node: &SchemaNode,
    prime_morphism: &mut PrimeMorphism,
    master_pv: &mut PrimeVector,
) {
    let node_name_pv = prime_morphism.string_to_char_prime_vector(&node.name);
    let json_type_str = format!("{:?}", node.json_type);
    let node_type_pv = prime_morphism.string_to_char_prime_vector(&json_type_str);

    let mut combined_pv = node_name_pv;
    combined_pv.multiply(&node_type_pv);

    // Incorporate count as an exponent (simplified, can be more complex)
    for (_prime, exponent) in &mut combined_pv.map {
        *exponent += node.count;
    }

    master_pv.multiply(&combined_pv);

    for (_key, child_node) in &node.children {
        traverse_schema_node_for_prime_vector(child_node, prime_morphism, master_pv);
    }
}

pub fn perform_iterative_schema_inference(initial_json_value: Value) -> Result<(Option<Schema>, Vec<IterationReport>), ThreadSafeError> {
    let mut current_json_value = initial_json_value;
    let mut final_schema: Option<Schema> = None;
    let mut all_iteration_reports: Vec<IterationReport> = Vec::new();

    for i in 0..8 {
        let schema = Schema::infer(&current_json_value, 8); // Limit recursion depth to 8
        
        all_iteration_reports.push(IterationReport {
            iteration: i + 1,
            schema: schema.root.clone(), // Store the root SchemaNode
        });

        current_json_value = schema.to_json_value(); // Convert schema to JSON data for next iteration
        final_schema = Some(schema); // Keep track of the final schema
    }
    Ok((final_schema, all_iteration_reports))
}
