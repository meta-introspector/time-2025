// lean_introspector/src/matrix_representation.rs
use std::collections::HashMap;


#[derive(Debug, serde::Serialize)]
pub struct SchemaMatrix {
    pub component_map: HashMap<String, usize>, // Maps component name to its index in the matrix
    pub matrix: Vec<Vec<u64>>, // Adjacency matrix: [from_component_index][to_component_index]
}

impl SchemaMatrix {
    pub fn new() -> Self {
        SchemaMatrix {
            component_map: HashMap::new(),
            matrix: Vec::new(),
        }
    }

    // This function will take a single schema (HashMap<String, JsonType>) and build a matrix from it.
    pub fn from_schema(schema_nodes: &HashMap<String, crate::schema_inference::JsonType>) -> Self {
        let mut matrix_rep = SchemaMatrix::new();
        let mut next_index = 0;

        // Collect all unique path components and assign them an index
        let mut all_components: Vec<String> = Vec::new();
        for path in schema_nodes.keys() {
            for component in path.split('.') {
                if !matrix_rep.component_map.contains_key(component) {
                    matrix_rep.component_map.insert(component.to_string(), next_index);
                    all_components.push(component.to_string()); // Keep track of order for matrix
                    next_index += 1;
                }
            }
        }

        // Initialize the matrix with zeros
        let size = next_index;
        matrix_rep.matrix = vec![vec![0; size]; size];

        // Fill the matrix based on component adjacency in paths
        for path in schema_nodes.keys() {
            let components: Vec<&str> = path.split('.').collect();
            for i in 0..(components.len() - 1) {
                let from_component = components[i];
                let to_component = components[i+1];

                let from_index = *matrix_rep.component_map.get(from_component).unwrap();
                let to_index = *matrix_rep.component_map.get(to_component).unwrap();

                matrix_rep.matrix[from_index][to_index] += 1;
            }
        }

        matrix_rep
    }
}
