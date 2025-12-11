// lean_introspector_lib/src/matrix_representation.rs
use serde::{Serialize, Deserialize};
use crate::schema_inference::{Schema, SchemaNode};
use std::collections::VecDeque;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SchemaMatrix {
    pub paths: Vec<String>,
}

impl SchemaMatrix {
    pub fn from_schema(schema: &Schema) -> Self {
        let mut paths = Vec::new();
        let mut queue: VecDeque<(&SchemaNode, String)> = VecDeque::new();

        queue.push_back((&schema.root, "root".to_string()));

        while let Some((node, current_path)) = queue.pop_front() {
            // Only add path if it's not the synthetic "root" of the actual data
            if current_path != "root" { // Exclude the synthetic "root" path
                 paths.push(current_path.clone());
            }

            for (key, child_node) in &node.children {
                let next_path = if current_path == "root" {
                    key.clone()
                } else {
                    format!("{}.{}", current_path, key)
                };
                queue.push_back((child_node, next_path));
            }
        }
        SchemaMatrix { paths }
    }

    pub fn to_paths(&self) -> Vec<String> {
        self.paths.clone()
    }
}