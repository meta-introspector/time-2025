// lean_introspector_lib/src/schema_inference.rs
use serde::{Serialize, Deserialize};
use serde_json::Value;
use std::collections::{HashMap, VecDeque};

// --- Chunk and Hyperedge Definitions ---
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Chunk {
    pub id: String,
    pub entity_type: String, // e.g., "Person", "Address", "owl:Collection<xsd:string>"
    pub value: Value, // The actual JSON value this chunk represents
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Hyperedge {
    pub predicate: String, // e.g., "hasAddress", "contains"
    pub node_ids: Vec<String>, // IDs of chunks connected by this hyperedge
    pub properties: Option<Value>, // Additional properties of the hyperedge (e.g., array index)
}

// --- JsonType Definition ---
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub enum JsonType {
    StringType,
    NumberType,
    IntegerType,
    BooleanType,
    ArrayType,
    ObjectType,
    NullType,
    UnknownType,
}

impl From<&Value> for JsonType {
    fn from(value: &Value) -> Self {
        match value {
            Value::Null => JsonType::NullType,
            Value::Bool(_) => JsonType::BooleanType,
            Value::Number(n) if n.is_i64() => JsonType::IntegerType,
            Value::Number(_) => JsonType::NumberType,
            Value::String(_) => JsonType::StringType,
            Value::Array(_) => JsonType::ArrayType,
            Value::Object(_) => JsonType::ObjectType,
        }
    }
}

// --- SchemaNode Definition ---
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SchemaNode {
    pub name: String, // The component name (e.g., "cnstInfB", "sig", "type")
    pub json_type: JsonType,
    pub children: HashMap<String, SchemaNode>, // For nested objects/arrays
    pub element: Option<Box<SchemaNode>>, // for arrays
}

// --- Schema Definition ---
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Schema {
    pub root: SchemaNode,
}

impl Schema {
    pub fn new_empty_root() -> SchemaNode {
        SchemaNode {
            name: "".to_string(), // Root has no name
            json_type: JsonType::ObjectType, // Assuming the root is always an object (the whole JSON)
            children: HashMap::new(),
            element: None,
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

        current_node.json_type = JsonType::from(value); // Update type based on actual json_value

        match value {
            Value::Object(map) => {
                for (key, val) in map {
                    let child_node = current_node.children.entry(key.clone()).or_insert_with(|| SchemaNode {
                        name: key.clone(),
                        json_type: JsonType::UnknownType, // Initial type guess, will be updated
                        children: HashMap::new(),
                        element: None,
                    });
                    Self::traverse_and_build(val, child_node, max_depth, current_depth + 1);
                }
            }
            Value::Array(arr) => {
                if !arr.is_empty() {
                    let mut element_node = match current_node.element.take() {
                        Some(node) => *node,
                        None => SchemaNode {
                            name: "item".to_string(), // Name for array elements
                            json_type: JsonType::UnknownType, // Initial type guess, will be updated
                            children: HashMap::new(),
                            element: None,
                        },
                    };
                    for val in arr {
                        Self::traverse_and_build(val, &mut element_node, max_depth, current_depth + 1);
                    }
                    current_node.element = Some(Box::new(element_node));
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

        if !node.children.is_empty() {
            let mut children_map = serde_json::Map::new();
            for (key, child_node) in &node.children {
                children_map.insert(key.clone(), Self::schema_node_to_json_value(child_node));
            }
            map.insert("children".to_string(), Value::Object(children_map));
        }

        if let Some(element_node) = &node.element {
            map.insert("element".to_string(), Self::schema_node_to_json_value(element_node));
        }

        Value::Object(map)
    }
}

// --- Helper to map JsonType to OWL/XSD like types ---
pub fn json_type_to_owl_type(json_type: &JsonType) -> String {
    match json_type {
        JsonType::StringType => "xsd:string".to_string(),
        JsonType::NumberType => "xsd:double".to_string(), // Assuming double for general numbers
        JsonType::IntegerType => "xsd:integer".to_string(),
        JsonType::BooleanType => "xsd:boolean".to_string(),
        JsonType::ArrayType => "owl:Collection".to_string(), // Represents a collection of items
        JsonType::ObjectType => "owl:Thing".to_string(), // Generic object, specific class name will be used for domain/range
        JsonType::NullType => "owl:Nothing".to_string(),
        JsonType::UnknownType => "rdfs:Literal".to_string(), // Fallback for unknown
    }
}

// --- Function to generate hypergraph representation ---
pub fn generate_hypergraph_representation(initial_json_value: &Value, final_schema: &Option<Schema>) -> Result<(Vec<Chunk>, Vec<Hyperedge>), String> {
    let mut chunks: HashMap<String, Chunk> = HashMap::new();
    let mut hyperedges = Vec::new();
    let mut queue: VecDeque<(&SchemaNode, &Value, String)> = VecDeque::new();

    if let Some(schema) = final_schema {
        queue.push_back((&schema.root, initial_json_value, "Root".to_string()));

        while let Some((schema_node, json_value, current_path)) = queue.pop_front() {
            let is_complex_type = schema_node.json_type == JsonType::ObjectType || schema_node.json_type == JsonType::ArrayType;

            if current_path == "Root".to_string() || is_complex_type {
                let entity_type = if schema_node.json_type == JsonType::ObjectType {
                    current_path.clone() // Use path as type name for objects
                } else if schema_node.json_type == JsonType::ArrayType {
                    format!("owl:Collection<{}>", schema_node.element.as_ref().map_or("owl:Thing".to_string(), |e| json_type_to_owl_type(&e.json_type)))
                } else {
                    json_type_to_owl_type(&schema_node.json_type) // Fallback for primitive root if it ever happens
                };

                let current_chunk_value = json_value.clone();
                let current_chunk_id = current_path.clone();

                if !chunks.contains_key(&current_chunk_id) {
                    chunks.insert(
                        current_chunk_id.clone(),
                        Chunk {
                            id: current_chunk_id.clone(),
                            entity_type: entity_type.clone(),
                            value: current_chunk_value,
                        },
                    );
                }
            }
            
            // Process children for relations and further traversal
            if schema_node.json_type == JsonType::ObjectType {
                if let Some(obj) = json_value.as_object() {
                    for (key, child_schema_node) in &schema_node.children {
                        if let Some(child_json_value) = obj.get(key) {
                            let child_path = format!("{}.{}", current_path, key);

                            // If child is a complex type, it's a relation and a new node to explore
                            if child_schema_node.json_type == JsonType::ObjectType || child_schema_node.json_type == JsonType::ArrayType {
                                hyperedges.push(Hyperedge {
                                    predicate: key.clone(),
                                    node_ids: vec![current_path.clone(), child_path.clone()], // Link parent to child
                                    properties: None,
                                });
                                queue.push_back((child_schema_node, child_json_value, child_path));
                            } else {
                                // Primitive child. Its value is embedded in the parent chunk.
                                // No separate chunk or hyperedge for primitives unless explicitly needed.
                            }
                        }
                    }
                }
            } else if schema_node.json_type == JsonType::ArrayType {
                if let Some(arr) = json_value.as_array() {
                    if let Some(element_schema_node) = &schema_node.element {
                        for (index, element_json_value) in arr.iter().enumerate() {
                            let element_path = format!("{}[{}]", current_path, index);
                            
                            // If element is a complex type, it's a relation and a new node to explore
                            if element_schema_node.json_type == JsonType::ObjectType || element_schema_node.json_type == JsonType::ArrayType {
                                hyperedges.push(Hyperedge {
                                    predicate: "has_element".to_string(), // Generic predicate for array elements
                                    node_ids: vec![current_path.clone(), element_path.clone()], // Link array to its element
                                    properties: Some(serde_json::json!({"index": index})),
                                });
                                queue.push_back((element_schema_node, element_json_value, element_path));
                            } else {
                                // Primitive element. Its value is embedded in the array chunk.
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Convert HashMap of chunks to Vec<Chunk>
    Ok((chunks.into_values().collect(), hyperedges))
}
