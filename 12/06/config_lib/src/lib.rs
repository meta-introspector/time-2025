use std::fs;
use std::path::{PathBuf};
use serde::Deserialize;
use std::env;

#[derive(Debug, Deserialize)]
struct RawConfig {
    dataset_path: String,
    input_file: String,
    split_max_depth: Option<usize>,
    schema_output_dir: String,
}

#[derive(Debug)]
pub struct Config {
    pub dataset_path: PathBuf,
    pub input_file: PathBuf,
    pub split_max_depth: Option<usize>,
    pub schema_output_dir: PathBuf,
}

#[derive(Debug, Clone)]
pub struct GenericError(pub String);

impl std::fmt::Display for GenericError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.0)
    }
}

impl std::error::Error for GenericError {}

pub type ThreadSafeError = Box<dyn std::error::Error + Send + Sync + 'static>;


pub fn find_and_read_config(config_file_name: &str) -> Result<(Config, PathBuf), ThreadSafeError> {
    let current_dir = env::current_dir().map_err(|e| Box::new(GenericError(format!("Failed to get current directory: {}", e))) as ThreadSafeError)?;
    
    let mut current_path = current_dir.as_path();

    loop {
        let config_path = current_path.join(config_file_name);
        if config_path.exists() {
            let config_str = fs::read_to_string(&config_path)
                .map_err(|e| Box::new(GenericError(format!("Failed to read config file '{}': {}", config_path.display(), e))) as ThreadSafeError)?;
    
            let raw_config: RawConfig = toml::from_str(&config_str)
                .map_err(|e| Box::new(GenericError(format!("Failed to parse config file '{}': {}", config_path.display(), e))) as ThreadSafeError)?;

            let base_dir = config_path.parent()
                .ok_or_else(|| Box::new(GenericError(format!("Config file path has no parent directory: {}", config_path.display()))) as ThreadSafeError)?;
            
            let dataset_path = base_dir.join(PathBuf::from(&raw_config.dataset_path))
                .canonicalize()
                .map_err(|e| Box::new(GenericError(format!("Failed to canonicalize dataset_path '{}': {}", base_dir.join(&raw_config.dataset_path).display(), e))) as ThreadSafeError)?;

            let input_file = dataset_path.join(PathBuf::from(&raw_config.input_file))
                .canonicalize()
                .map_err(|e| Box::new(GenericError(format!("Failed to canonicalize input_file '{}': {}", dataset_path.join(&raw_config.input_file).display(), e))) as ThreadSafeError)?;

            let schema_output_dir = base_dir.join(PathBuf::from(&raw_config.schema_output_dir));

            let config = Config {
                dataset_path,
                input_file,
                split_max_depth: raw_config.split_max_depth,
                schema_output_dir,
            };

            return Ok((config, base_dir.to_path_buf()));
        }

        if let Some(parent) = current_path.parent() {
            current_path = parent;
        } else {
            return Err(Box::new(GenericError(format!("Could not find '{}' in current directory or any parent directory.", config_file_name))) as ThreadSafeError);
        }
    }
}