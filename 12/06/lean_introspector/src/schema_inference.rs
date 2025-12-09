// lean_introspector/src/schema_inference.rs
use std::collections::HashMap;
use serde_json::Value;
use serde::Serialize; // Ensure Serialize is imported

#[derive(Debug, PartialEq, Eq, Hash, Serialize, Clone)]
pub enum JsonType {
    Null,
    Bool,
    Number,
    String,
    Array,
    Object,
}

impl From<&Value> for JsonType {
    fn from(value: &Value) -> Self {
        match value {
            Value::Null => JsonType::Null,
            Value::Bool(_) => JsonType::Bool,
            Value::Number(_) => JsonType::Number,
            Value::String(_) => JsonType::String,
            Value::Array(_) => JsonType::Array,
            Value::Object(_) => JsonType::Object,
        }
    }
}

#[derive(Debug, Serialize, Clone)]
pub struct SchemaNode {
    pub name: String, // The component name (e.g., "cnstInfB", "sig", "type")
    pub json_type: JsonType,
    pub children: HashMap<String, SchemaNode>, // For nested objects/arrays
    pub count: u64, // How many times this pattern/node appeared
}

#[derive(Debug, Serialize, Clone)]
pub struct Schema {
    pub root: SchemaNode,
}

impl Schema {
    pub fn new_empty_root() -> SchemaNode {
        SchemaNode {
            name: "".to_string(), // Root has no name
            json_type: JsonType::Object, // Assuming the root is always an object (the whole JSON)
            children: HashMap::new(),
            count: 0,
        }
    }

    pub fn infer(json_value: &Value, max_depth: usize) -> Self {
        let mut root_node = Self::new_empty_root();
        Self::traverse_and_build(json_value, &mut root_node, max_depth, 0);
        Schema { root: root_node }
    }

    fn traverse_and_build(value: &Value, current_node: &mut SchemaNode, max_depth: usize, current_depth: usize) {
        if current_depth > max_depth {
            return; // Stop recursing
        }
        current_node.count += 1;
        current_node.json_type = JsonType::from(value); // Update type based on actual json_value

        match value {
            Value::Object(map) => {
                for (key, val) in map {
                    let child_node = current_node.children.entry(key.clone()).or_insert_with(|| SchemaNode {
                        name: key.clone(),
                        json_type: JsonType::from(val), // Initial type guess
                        children: HashMap::new(),
                        count: 0,
                    });
                    Self::traverse_and_build(val, child_node, max_depth, current_depth + 1);
                }
            }
            Value::Array(arr) => {
                if !arr.is_empty() {
                    let array_element_node = current_node.children.entry("[]".to_string()).or_insert_with(|| SchemaNode {
                        name: "[]".to_string(),
                        json_type: JsonType::from(&arr[0]), // Initial type guess from first element
                        children: HashMap::new(),
                        count: 0,
                    });
                    for val in arr {
                        Self::traverse_and_build(val, array_element_node, max_depth, current_depth + 1);
                    }
                }
            }
            _ => {} // Leaf node
        }
    }

    pub fn to_json_value(&self) -> Value {
        Self::schema_node_to_json_value(&self.root)
    }

    fn schema_node_to_json_value(node: &SchemaNode) -> Value {
        let mut map = serde_json::Map::new();
        
        map.insert("name".to_string(), Value::String(node.name.clone()));
        map.insert("json_type".to_string(), Value::String(format!("{:?}", node.json_type)));
        map.insert("count".to_string(), Value::Number(serde_json::Number::from(node.count)));

        if !node.children.is_empty() {
            let mut children_map = serde_json::Map::new();
            for (key, child_node) in &node.children {
                children_map.insert(key.clone(), Self::schema_node_to_json_value(child_node));
            }
            map.insert("children".to_string(), Value::Object(children_map));
        }
        Value::Object(map)
    }
}
