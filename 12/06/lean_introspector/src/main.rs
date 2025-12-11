use std::fs::{self, File};
use std::io::Read;
use std::path::Path;
use serde::Deserialize;
use serde_json::Value;
use lean_introspector_lib::schema_inference::{Chunk, Hyperedge, Schema, SchemaNode, JsonType, json_type_to_owl_type, generate_hypergraph_representation};
use lean_introspector_lib::prime_analysis::{PrimeVector, PrimeMorphism};
use lean_introspector_lib::report::{Report, IterationReport};
use lean_introspector_lib::matrix_representation::SchemaMatrix;
use std::collections::{HashMap, VecDeque};
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
    schema: &Schema,
) -> Result<(Option<SchemaMatrix>, Option<Vec<Complex<f64>>>, Option<Vec<Array1<Complex<f64>>>>), ThreadSafeError> {
    let mut schema_matrix_opt: Option<SchemaMatrix> = None;
    let eigenvalues_opt: Option<Vec<Complex<f64>>> = None; // Always None for now
    let eigenvectors_opt: Option<Vec<Array1<Complex<f64>>>> = None; // Always None for now

    let sm = SchemaMatrix::from_schema(schema);
    
    // Eigenvalue/eigenvector decomposition is disabled as BLAS/LAPACK backends are commented out
    schema_matrix_opt = Some(sm);
    Ok((schema_matrix_opt, eigenvalues_opt, eigenvectors_opt))
}


fn generate_and_save_report(
    final_schema: &Option<Schema>,
    all_iteration_reports: Vec<IterationReport>,
    schema_matrix_opt: Option<SchemaMatrix>,
    eigenvalues_opt: Option<Vec<Complex<f64>>> ,
    eigenvectors_opt: Option<Vec<Array1<Complex<f64>>>>,
) -> Result<(), ThreadSafeError> {
    let mut master_prime_vector_map = HashMap::new();
    if let Some(schema) = final_schema { // Removed 'ref'
        let mut prime_morphism = PrimeMorphism::new(HashMap::new());
        let mut master_prime_vector = PrimeVector::new();

        traverse_schema_node_for_prime_vector(&schema.root, &mut prime_morphism, &mut master_prime_vector);
        master_prime_vector_map = master_prime_vector.map;
        println!("INFO: Prime vectors generated for final schema.");
        println!("\nMaster Prime Vector: {:?}", master_prime_vector_map);
    }


    let report = Report {
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


// New helper function to get value at a given JSON path
fn get_value_at_path<'a>(json_value: &'a Value, path: &str) -> Option<&'a Value> {
    let mut current_value = json_value;
    for segment in path.split('.') {
        if segment.contains('[') && segment.contains(']') {
            // Handle array access like "field[index]"
            let parts: Vec<&str> = segment.split('[').collect();
            if parts.len() == 2 {
                let field_name = parts[0];
                let index_str = parts[1].trim_end_matches(']');
                if let Ok(index) = index_str.parse::<usize>() {
                    if let Some(obj) = current_value.as_object() {
                        current_value = obj.get(field_name)?;
                        current_value = current_value.as_array()?.get(index)?;
                    } else if field_name.is_empty() { // Case like "[0]" directly on an array
                         current_value = current_value.as_array()?.get(index)?;
                    } else {
                        return None;
                    }
                } else {
                    return None;
                }
            } else {
                return None;
            }
        } else {
            // Handle object field access
            current_value = current_value.as_object()?.get(segment)?;
        }
    }
    Some(current_value)
}


// Function to generate the ontology report
fn generate_ontology_report(final_schema: &Option<Schema>) -> Result<String, ThreadSafeError> {
    const MAX_ONTOLOGY_TRIPLES: usize = 20;
    let mut report_lines = Vec::new();
    report_lines.push("# Ontology Triples from Schema Analysis\n".to_string());
    report_lines.push(format!("A sample of (Subject, Predicate, Object) triples (limited to {}):\n", MAX_ONTOLOGY_TRIPLES));

    let mut triples: Vec<(String, String, String)> = Vec::new();
    let mut queue: VecDeque<(&SchemaNode, Vec<String>)> = VecDeque::new();

    if let Some(schema) = final_schema {
        queue.push_back((&schema.root, Vec::new()));

        while let Some((node, path_segments)) = queue.pop_front() {
            let current_subject_base = if path_segments.is_empty() {
                "Root".to_string()
            } else {
                path_segments.join(".")
            };

            // If the current node is an object or an array of objects, process its children as properties
            if node.json_type == JsonType::ObjectType
                || (node.json_type == JsonType::ArrayType
                    && node.children.values().next().map_or(false, |child| child.json_type == JsonType::ObjectType))
            {
                // Iterate over children (properties)
                for (prop_name, child_node) in &node.children {
                    if triples.len() >= MAX_ONTOLOGY_TRIPLES {
                        break;
                    }

                    let predicate = prop_name.clone();
                    let object = if child_node.json_type == JsonType::ObjectType {
                        // If the child is an object, its object is a new class
                        format!("{}.{}", current_subject_base, prop_name)
                    } else if child_node.json_type == JsonType::ArrayType {
                        // If array, its object is a collection, and potentially a new class for its elements
                        let element_type = if let Some(element_schema) = child_node.element.as_ref() {
                            if element_schema.json_type == JsonType::ObjectType {
                                format!("{}.{}", current_subject_base, prop_name) // Name the array elements after the path
                            } else {
                                json_type_to_owl_type(&element_schema.json_type)
                            }
                        } else {
                            json_type_to_owl_type(&child_node.json_type) // Fallback for primitive elements
                        };
                        format!("owl:Collection<{}>", element_type)
                    }
                    else {
                        // Otherwise, it's a primitive type
                        json_type_to_owl_type(&child_node.json_type)
                    };
                    
                    triples.push((current_subject_base.clone(), predicate, object));
                    
                    // Push child node for further traversal if it's a complex type
                    if child_node.json_type == JsonType::ObjectType
                        || child_node.json_type == JsonType::ArrayType
                    {
                        let mut next_path_segments = path_segments.clone();
                        next_path_segments.push(prop_name.clone());
                        queue.push_back((child_node, next_path_segments));
                    }
                }
            }
        }
    } else {
        report_lines.push("  No schema available to generate ontology.\n".to_string());
    }

    for (s, p, o) in triples {
        report_lines.push(format!("  (\"{}\", \"{}\", \"{}\"", s, p, o))
    }

    Ok(report_lines.join(""))
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

            let ontology_report = generate_ontology_report(&final_schema)?;
            println!("\n{}", ontology_report);
            println!("INFO: Ontology report generated and printed.");

            println!("INFO: Generating hypergraph representation...");
            let (chunks, hyperedges) = generate_hypergraph_representation(&initial_json_value, &final_schema).map_err(|e| Box::new(GenericError(e)) as ThreadSafeError)?;
            println!("\nHypergraph Chunks: {}", serde_json::to_string_pretty(&chunks).map_err(|e| Box::new(e) as ThreadSafeError)?);
            println!("\nHypergraph Hyperedges: {}", serde_json::to_string_pretty(&hyperedges).map_err(|e| Box::new(e) as ThreadSafeError)?);
            println!("INFO: Hypergraph representation generated and printed.");

            let (schema_matrix_opt, eigenvalues_opt, eigenvectors_opt) = 
                if let Some(schema_val) = final_schema.as_ref() { // Use .as_ref() to borrow
                    println!("\nJSON representation of the inferred schema:");
                    let schema_json_value = schema_val.to_json_value();
                    println!("{}", serde_json::to_string_pretty(&schema_json_value).map_err(|e| Box::new(e) as ThreadSafeError)?);

                    println!("INFO: Generating schema matrix and eigen decomposition...");
                    let res = generate_schema_matrix_and_eigen(schema_val)?;
                    println!("INFO: Schema matrix and eigen decomposition complete.");
                    res
                } else {
                    (None, None, None)
                };

            // Call to_paths and print
            if let Some(ref sm) = schema_matrix_opt {
                let all_paths: Vec<String> = sm.to_paths();
                let total_paths = all_paths.len(); // Get length before moving
                println!("\nMapping Original Data to Inferred Paths (Limited to {} of {}):", MAX_RECONSTRUCTED_PATHS_TO_PRINT, total_paths);
                let mut count = 0;
                for path_str in all_paths.into_iter() { // Now `all_paths` is moved here
                    if count >= MAX_RECONSTRUCTED_PATHS_TO_PRINT {
                        println!("  Path: \"{}\" -> Value: {}", path_str, serde_json::to_string_pretty(get_value_at_path(&initial_json_value, &path_str).unwrap_or(&Value::Null)).unwrap_or_else(|_| "[Error converting value]".to_string()));
                    } else {
                        println!("  Path: \"{}\" -> Value: [Not Found or Invalid Path]", path_str);
                    }
                    count += 1;
                }
                println!("INFO: Mapped data to inferred paths printed.");
            }

            println!("INFO: Generating and saving analysis report...");
            generate_and_save_report(
                &final_schema,
                all_iteration_reports,
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
