// lean_introspector/src/report.rs
use std::collections::HashMap;
use serde::Serialize;
 // Added
use lean_introspector_lib::schema_inference::SchemaNode;
use lean_introspector_lib::matrix_representation::SchemaMatrix;
use num_complex::Complex;
use ndarray::Array1;

#[derive(Debug, Serialize)]
pub struct Report {
    pub initial_json_value: serde_json::Value, // Added
    pub iterations: Vec<IterationReport>,
    pub master_prime_vector: HashMap<u64, u64>,
    pub schema_matrix: Option<SchemaMatrix>, // New field for the matrix representation
    pub eigenvalues: Option<Vec<Complex<f64>>>, // New field for eigenvalues
    pub eigenvectors: Option<Vec<Array1<Complex<f64>>>>, // New field for eigenvectors
}

#[derive(Debug, Serialize)]
pub struct IterationReport {
    pub iteration: usize,
    pub schema: SchemaNode, // Change from HashMap<String, JsonType> to SchemaNode
}
