// lean_introspector/src/config.rs
use std::fs;
use std::io::Read; // Added
use std::path::{Path, PathBuf};
use serde::Deserialize;
use serde_json::Value;

use crate::error::ThreadSafeError;
use crate::schema_inference::Schema;
use crate::report::IterationReport;

#[derive(Deserialize)]
pub struct Config {
    pub dataset_path: String,
    pub input_file: String,
    pub backend: String,
}

pub fn read_config() -> Result<Config, ThreadSafeError> {
    let config_str = fs::read_to_string("config.toml")
        .map_err(|e| Box::new(e) as ThreadSafeError)?;
    let config: Config = toml::from_str(&config_str)
        .map_err(|e| Box::new(e) as ThreadSafeError)?;
    Ok(config)
}

pub fn get_input_file_path(config: &Config) -> PathBuf {
    Path::new(&config.dataset_path)
        .join(&config.input_file)
}

pub fn read_input_json(config: &Config) -> Result<Value, ThreadSafeError> {
    let file_path = get_input_file_path(config);

    let mut file = fs::File::open(&file_path)
        .map_err(|e| Box::new(e) as ThreadSafeError)?;
    let mut json_str = String::new();
    file.read_to_string(&mut json_str)
        .map_err(|e| Box::new(e) as ThreadSafeError)?;

    let initial_json_value: Value = serde_json::from_str(&json_str)
        .map_err(|e| Box::new(e) as ThreadSafeError)?;
    Ok(initial_json_value)
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
