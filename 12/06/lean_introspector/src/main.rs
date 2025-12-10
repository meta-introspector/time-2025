use std::fs::{self, File};
use std::io::Read;
use std::path::Path;
use serde::Deserialize;
use serde_json::Value;
use lean_introspector_lib::schema_inference::{Schema, SchemaNode};
use lean_introspector_lib::prime_analysis::{PrimeVector, PrimeMorphism};
use lean_introspector_lib::report::{Report, IterationReport};
use lean_introspector_lib::matrix_representation::SchemaMatrix;
use std::collections::HashMap;
use ndarray::Array1;
use num_complex::Complex;
use lean_introspector_lib::emojilisp;
// use libfaalg_adaptor::{LibfaalgAdaptor, LinearAlgebraAdaptor};

const MAX_RECONSTRUCTED_PATHS_TO_PRINT: usize = 100; // Limit to 100 paths for brevity

#[derive(Deserialize)]
struct Config {
    dataset_path: String,
    input_file: String,
}

// Helper function to traverse SchemaNode and generate PrimeVector
fn traverse_schema_node_for_prime_vector(
    node: &SchemaNode,
    prime_morphism: &mut PrimeMorphism,
    master_pv: &mut PrimeVector,
) {
    let node_name_pv = prime_morphism.string_to_char_prime_vector(&node.name);
    let json_type_str = format!("{:?}", node.json_type);
    let node_type_pv = prime_morphism.string_to_char_prime_vector(&json_type_str);

    let mut combined_pv = node_name_pv;
    combined_pv.multiply(&node_type_pv);

    // Incorporate count as an exponent (simplified, can be more complex)
    for (_prime, exponent) in &mut combined_pv.map {
        *exponent += node.count;
    }

    master_pv.multiply(&combined_pv);

    for (_key, child_node) in &node.children {
        traverse_schema_node_for_prime_vector(child_node, prime_morphism, master_pv);
    }
}

#[derive(Debug)]
struct GenericError(String);

impl std::fmt::Display for GenericError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}", self.0)
    }
}

impl std::error::Error for GenericError {}

type ThreadSafeError = Box<dyn std::error::Error + Send + 'static>;


// New helper functions
fn read_config() -> Result<(Config, std::path::PathBuf), ThreadSafeError> {
    use std::env;
    let mut config_path_buf = env::current_dir().map_err(|e| Box::new(e) as ThreadSafeError)?;
    config_path_buf.push("lean_introspector");
    let config_dir = config_path_buf.clone(); // Store the directory path
    config_path_buf.push("config.toml");
    
    let config_str = fs::read_to_string(&config_path_buf)
        .map_err(|e| Box::new(e) as ThreadSafeError)?;
    let config: Config = toml::from_str(&config_str)
        .map_err(|e| Box::new(e) as ThreadSafeError)?;
    Ok((config, config_dir))
}

fn get_input_file_path(config: &Config, base_dir: &Path) -> std::path::PathBuf {
    base_dir.join(&config.dataset_path)
        .join(&config.input_file)
}

fn read_input_json(file_path: &Path) -> Result<Value, ThreadSafeError> {
    eprintln!("Debug: Attempting to locate data file: {}", file_path.display());
    let canonical_file_path = file_path.canonicalize().unwrap_or_else(|_| {
        eprintln!("Error: Could not canonicalize data path: {}", file_path.display());
        file_path.to_path_buf()
    });
    eprintln!("Debug: Absolute data path: {}", canonical_file_path.display());
    if !canonical_file_path.exists() {
        eprintln!("Error: Data file does NOT exist at: {}", canonical_file_path.display());
    }
    if !canonical_file_path.is_file() {
        eprintln!("Error: Data path is NOT a file: {}", canonical_file_path.display());
    }

    let mut file = File::open(&file_path)
        .map_err(|e| {
            Box::new(GenericError(format!("Failed to open input JSON file '{}': {}", file_path.display(), e))) as ThreadSafeError
        })?;
    let mut json_str = String::new();
    file.read_to_string(&mut json_str)
        .map_err(|e| {
            Box::new(GenericError(format!("Failed to read input JSON file '{}': {}", file_path.display(), e))) as ThreadSafeError
        })?;

    let initial_json_value: Value = serde_json::from_str(&json_str)
        .map_err(|e| Box::new(e) as ThreadSafeError)?;
    Ok(initial_json_value)
}

fn perform_iterative_schema_inference(initial_json_value: Value) -> Result<(Option<Schema>, Vec<IterationReport>), ThreadSafeError> {
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

fn generate_schema_matrix_and_eigen(
    final_schema: &Option<Schema>,
) -> Result<(Option<SchemaMatrix>, Option<Vec<Complex<f64>>>, Option<Vec<Array1<Complex<f64>>>>), ThreadSafeError> {
    let mut schema_matrix_opt: Option<SchemaMatrix> = None;
    let eigenvalues_opt: Option<Vec<Complex<f64>>> = None; // Always None for now
    let eigenvectors_opt: Option<Vec<Array1<Complex<f64>>>> = None; // Always None for now

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
        
        // Eigenvalue/eigenvector decomposition is disabled as BLAS/LAPACK backends are commented out
        schema_matrix_opt = Some(sm);
    }
    Ok((schema_matrix_opt, eigenvalues_opt, eigenvectors_opt))
}


fn generate_and_save_report(
    initial_json_value: Value,
    all_iteration_reports: Vec<IterationReport>,
    master_prime_vector_map: HashMap<u64, u64>,
    schema_matrix_opt: Option<SchemaMatrix>,
    eigenvalues_opt: Option<Vec<Complex<f64>>> ,
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

fn recursive_split_json(value: &Value, path: &Path) -> Result<(), ThreadSafeError> {
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


fn main() -> Result<(), ThreadSafeError> {
    const STACK_SIZE: usize = 4 * 1024 * 1024; // 4MB stack size, adjust as needed

    let child_builder = std::thread::Builder::new()
        .stack_size(STACK_SIZE)
        .spawn(move || -> Result<(), ThreadSafeError> {
            let (config, config_dir) = read_config()?;
            println!("INFO: Config loaded and config directory identified.");

            let data_input_path = get_input_file_path(&config, &config_dir);
            println!("INFO: Input data path resolved to: {}", data_input_path.display());

            let output_dir = Path::new("output/formatting");
            fs::create_dir_all(&output_dir).map_err(|e| Box::new(e) as ThreadSafeError)?;
            println!("INFO: Output formatting directory ensured.");

            let initial_json_value = read_input_json(&data_input_path)?;
            println!("INFO: Initial JSON value read from input file.");

            println!("\nEmoji-Lisp representation of initial JSON:");
            let emoji_lisp_string = emojilisp::json_to_emoji_lisp_string(&initial_json_value);
            println!("{}", emoji_lisp_string);
            println!("INFO: Emoji-Lisp representation generated.");

            // Recursive split logic
            let split_output_path = Path::new("output/split");
            if split_output_path.exists() {
                fs::remove_dir_all(split_output_path).map_err(|e| Box::new(e) as ThreadSafeError)?;
                println!("INFO: Existing split output directory removed.");
            }
            println!("INFO: Starting recursive JSON splitting...");
            recursive_split_json(&initial_json_value, split_output_path)?;
            println!("INFO: Recursive JSON splitting complete.");

            println!("INFO: Starting iterative schema inference...");
            let (final_schema, all_iteration_reports) =
                perform_iterative_schema_inference(initial_json_value.clone())?;
            println!("INFO: Iterative schema inference complete.");

            let mut prime_morphism = PrimeMorphism::new(HashMap::new());
            let mut master_prime_vector = PrimeVector::new();

            if let Some(ref schema) = final_schema {
                traverse_schema_node_for_prime_vector(&schema.root, &mut prime_morphism, &mut master_prime_vector);
                println!("INFO: Prime vectors generated for final schema.");
            }

            println!("INFO: Generating schema matrix and eigen decomposition...");
            let (schema_matrix_opt, eigenvalues_opt, eigenvectors_opt) =
                generate_schema_matrix_and_eigen(&final_schema)?;
            println!("INFO: Schema matrix and eigen decomposition complete.");

            // // Call to_paths and print
            // if let Some(ref sm) = schema_matrix_opt {
            //     let all_paths: Vec<String> = sm.to_paths();
            //     let total_paths = all_paths.len(); // Get length before moving
            //     println!("\nReconstructed Paths from SchemaMatrix (Limited to {} of {}):", MAX_RECONSTRUCTED_PATHS_TO_PRINT, total_paths);
            //     let mut count = 0;
            //     for path in all_paths.into_iter() { // Now `all_paths` is moved here
            //         if count >= MAX_RECONSTRUCTED_PATHS_TO_PRINT {
            //             println!("... ({} more paths not shown)", total_paths - count);
            //             break;
            //         }
            //         println!("{}", path);
            //         count += 1;
            //     }
            //     println!("INFO: Reconstructed paths printed.");
            // }

            println!("INFO: Generating and saving analysis report...");
            generate_and_save_report(
                initial_json_value,
                all_iteration_reports,
                master_prime_vector.map,
                schema_matrix_opt, // Pass the generated schema_matrix_opt
                eigenvalues_opt,
                eigenvectors_opt,
            )?;
            println!("INFO: Analysis report saved.");

            Ok(())
        })
        .map_err(|e| Box::new(e) as ThreadSafeError)?; // Handle std::io::Error from spawn

    let thread_result = child_builder.join()
        .map_err(|e| {
            if let Some(s) = e.downcast_ref::<String>() {
                Box::new(GenericError(format!("Thread panicked: {}", s))) as ThreadSafeError
            } else if let Some(s) = e.downcast_ref::<&str>() {
                Box::new(GenericError(format!("Thread panicked: {}", s))) as ThreadSafeError
            } else {
                Box::new(GenericError("Thread panicked with an unknown error".to_string())) as ThreadSafeError
            }
        })?;

    thread_result
}