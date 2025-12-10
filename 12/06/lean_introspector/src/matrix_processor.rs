// lean_introspector/src/matrix_processor.rs
use std::collections::HashMap;

use ndarray::{Array1, Array2};
use num_complex::Complex;

use crate::error::{GenericError, ThreadSafeError};
use crate::schema_inference::Schema;
use crate::matrix_representation::SchemaMatrix;
use crate::decomposition::DecompositionAdaptor;
use crate::driver_factory::get_decomposition_driver;

pub fn generate_schema_matrix_and_eigen(
    final_schema: &Option<Schema>,
    backend_name: &str,
) -> Result<(Option<SchemaMatrix>, Option<Vec<Complex<f64>>>, Option<Vec<Array1<Complex<f64>>>>), ThreadSafeError> {
    let mut schema_matrix_opt: Option<SchemaMatrix> = None;
    let mut eigenvalues_opt: Option<Vec<Complex<f64>>> = None;
    let mut eigenvectors_opt: Option<Vec<Array1<Complex<f64>>>> = None;

    if let Some(schema) = final_schema {
        let mut final_schema_paths = HashMap::new();
        let mut path_stack = vec![("".to_string(), &schema.root)];

        while let Some((current_path_str, current_node)) = path_stack.pop() {
            if !current_path_str.is_empty() {
                final_schema_paths.insert(current_path_str.clone(), current_node.json_type.clone());
            }
            for (key, child_node) in &current_node.children {
                let next_path_str = if current_path_str.is_empty() {
                    key.clone()
                } else {
                    format!("{}.{}", current_path_str, key)
                };
                path_stack.push((next_path_str, child_node));
            }
        }
        let sm = SchemaMatrix::from_schema(&final_schema_paths);
        
        let size = sm.matrix.len();
        if size > 0 {
            let mut data = Vec::with_capacity(size * size);
            for row in &sm.matrix {
                for &val in row {
                    data.push(val as f64);
                }
            }
            let ndarray_matrix = Array2::from_shape_vec((size, size), data)
                .map_err(|e| Box::new(GenericError(format!("Failed to create Array2 from data: {}", e))) as ThreadSafeError)?;


            let driver = get_decomposition_driver(backend_name)
                .map_err(|e| Box::new(GenericError(e)) as ThreadSafeError)?;

            if let Some((eigenvalues, eigenvectors)) = driver.eigen_decompose(&ndarray_matrix) {
                eigenvalues_opt = Some(eigenvalues);
                eigenvectors_opt = Some(eigenvectors);
            } else {
                eprintln!("Warning: Eigen decomposition failed for the schema matrix with {} backend.", backend_name);
            }
        }
        schema_matrix_opt = Some(sm);
    }
    Ok((schema_matrix_opt, eigenvalues_opt, eigenvectors_opt))
}