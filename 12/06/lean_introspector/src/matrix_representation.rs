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

    pub fn to_paths(&self) -> Vec<String> {
        let mut paths = Vec::new();
        let index_to_component: HashMap<usize, String> = self.component_map.iter().map(|(k, v)| (*v, k.clone())).collect();

        let size = self.matrix.len();
        if size == 0 {
            return paths;
        }

        // Identify potential root components (those with no incoming edges or the "root" itself)
        // For simplicity, we'll assume any component can be a starting point and filter later.
        // A more sophisticated approach would look at in-degrees.

        for start_node_index in 0..size {
            let start_component = index_to_component.get(&start_node_index).unwrap().clone();
            let mut stack = vec!((start_node_index, start_component.clone()));
            let mut current_path_segments: Vec<String> = vec![start_component.clone()];

            while let Some((node_index, component_name)) = stack.pop() {
                // If we've finished processing a path, add it if it's not just a single component
                if node_index == start_node_index && current_path_segments.len() > 1 {
                    paths.push(current_path_segments.join("."));
                }

                let mut has_outgoing_edge = false;
                for next_node_index in 0..size {
                    if self.matrix[node_index][next_node_index] > 0 {
                        has_outgoing_edge = true;
                        let next_component_name = index_to_component.get(&next_node_index).unwrap().clone();
                        
                        // Push to stack for DFS
                        stack.push((next_node_index, next_component_name.clone()));
                        current_path_segments.push(next_component_name);
                    }
                }

                // If no outgoing edges, this is an end of a path
                if !has_outgoing_edge && current_path_segments.len() > 0 {
                    paths.push(current_path_segments.join("."));
                }

                // Backtrack if not at the start and no outgoing edges processed
                if !has_outgoing_edge && current_path_segments.len() > 1 && stack.last().map(|s| &s.0) != Some(&node_index) {
                     current_path_segments.pop();
                }
            }
        }

        // The current DFS approach might generate redundant paths or paths that don't make sense.
        // A more robust DFS for path reconstruction:
        paths.clear(); // Clear previous attempts
        let mut visited_paths = HashMap::new(); // To store unique paths and prevent duplicates

        for start_node_index in 0..size {
            let start_component = index_to_component.get(&start_node_index).unwrap();
            let mut path_stack = vec!((start_node_index, start_component.clone(), vec![start_component.clone()])); // (index, name, current_path_segments)

            while let Some((current_idx, current_name, current_segments)) = path_stack.pop() {
                // If this is a terminal node or we've reached a max depth (to prevent cycles)
                let mut is_terminal = true;
                for next_idx in 0..size {
                    if self.matrix[current_idx][next_idx] > 0 {
                        is_terminal = false;
                        let next_component = index_to_component.get(&next_idx).unwrap().clone();
                        let mut next_segments = current_segments.clone();
                        next_segments.push(next_component.clone());
                        path_stack.push((next_idx, next_component, next_segments));
                    }
                }

                if is_terminal && !current_segments.is_empty() {
                    let full_path = current_segments.join(".");
                    if visited_paths.insert(full_path.clone(), true).is_none() {
                        paths.push(full_path);
                    }
                }
            }
        }


        // Filter out single-component paths unless they are actual root nodes (e.g., from an empty path)
        paths.retain(|p| p.contains('.'));

        paths
    }
}
