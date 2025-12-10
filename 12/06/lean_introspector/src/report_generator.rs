// lean_introspector/src/report_generator.rs
use std::fs;
use std::path::Path;
use std::collections::HashMap;

use serde_json::Value;
use ndarray::Array1;
use num_complex::Complex;

use crate::error::ThreadSafeError;
use crate::report::{Report, IterationReport};
use crate::matrix_representation::SchemaMatrix;

pub fn generate_and_save_report(
    initial_json_value: Value,
    all_iteration_reports: Vec<IterationReport>,
    master_prime_vector_map: HashMap<u64, u64>,
    schema_matrix_opt: Option<SchemaMatrix>,
    eigenvalues_opt: Option<Vec<Complex<f64>>>,
    eigenvectors_opt: Option<Vec<Array1<Complex<f64>>>>,
) -> Result<(), ThreadSafeError> {
    let report = Report {
        initial_json_value,
        iterations: all_iteration_reports,
        master_prime_vector: master_prime_vector_map,
        schema_matrix: schema_matrix_opt,
        eigenvalues: eigenvalues_opt,
        eigenvectors: eigenvectors_opt,
    };

    let report_json = serde_json::to_string_pretty(&report)
        .map_err(|e| Box::new(e) as ThreadSafeError)?;
    fs::write("analysis_report.json", report_json)
        .map_err(|e| Box::new(e) as ThreadSafeError)?;
    println!("\nAnalysis report saved to analysis_report.json");
    Ok(())
}

pub fn recursive_split_json(value: &Value, path: &Path) -> Result<(), ThreadSafeError> {
    fs::create_dir_all(path).map_err(|e| Box::new(e) as ThreadSafeError)?;

    match value {
        Value::Object(map) => {
            let mut report = serde_json::Map::new();
            for (key, val) in map {
                if val.is_object() || val.is_array() {
                    report.insert(key.clone(), serde_json::json!({ "$ref": format!("./{}/_report.json", key) }));
                    recursive_split_json(val, &path.join(key))?;
                } else {
                    report.insert(key.clone(), val.clone());
                }
            }
            let report_content = serde_json::to_string_pretty(&Value::Object(report))
                .map_err(|e| Box::new(e) as ThreadSafeError)?;
            fs::write(path.join("_report.json"), report_content)
                .map_err(|e| Box::new(e) as ThreadSafeError)?;
        }
        Value::Array(arr) => {
            let mut report = Vec::new();
            for (i, val) in arr.iter().enumerate() {
                let subdir_name = i.to_string();
                if val.is_object() || val.is_array() {
                    report.push(serde_json::json!({ "$ref": format!("./{}/_report.json", subdir_name) }));
                    recursive_split_json(val, &path.join(&subdir_name))?;
                } else {
                    report.push(val.clone());
                }
            }
            let report_content = serde_json::to_string_pretty(&Value::Array(report))
                .map_err(|e| Box::new(e) as ThreadSafeError)?;
            fs::write(path.join("_report.json"), report_content)
                .map_err(|e| Box::new(e) as ThreadSafeError)?;
        }
        _ => {
            let value_content = serde_json::to_string_pretty(value)
                .map_err(|e| Box::new(e) as ThreadSafeError)?;
            fs::write(path.join("_value.json"), value_content)
                .map_err(|e| Box::new(e) as ThreadSafeError)?;
        }
    }
    Ok(())
}
