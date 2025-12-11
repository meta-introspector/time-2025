// lean_introspector_lib/src/report.rs
use serde::{Serialize, Deserialize};
use serde_json::Value;
use std::collections::HashMap;
use ndarray::Array1;
use num_complex::Complex;
use crate::matrix_representation::SchemaMatrix; // Assuming this will be created

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct IterationReport {
    pub iteration: usize,
    pub schema: crate::schema_inference::SchemaNode,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct Report {
    pub iterations: Vec<IterationReport>,
    pub master_prime_vector: HashMap<u64, u64>,
    pub schema_matrix: Option<SchemaMatrix>, // Assuming this will be created
    pub eigenvalues: Option<Vec<Complex<f64>>>,
    pub eigenvectors: Option<Vec<Array1<Complex<f64>>>>,
}