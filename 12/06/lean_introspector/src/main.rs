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


#[derive(Deserialize)]
struct Config {
    dataset_path: String,
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

fn main() -> Result<(), ThreadSafeError> {
    const STACK_SIZE: usize = 4 * 1024 * 1024; // 4MB stack size, adjust as needed

    let child_builder = std::thread::Builder::new()
        .stack_size(STACK_SIZE)
        .spawn(move || -> Result<(), ThreadSafeError> {
            let config_str = fs::read_to_string("config.toml")
                .map_err(|e| Box::new(e) as ThreadSafeError)?;
            let config: Config = toml::from_str(&config_str)
                .map_err(|e| Box::new(e) as ThreadSafeError)?;

            let file_path = Path::new(&config.dataset_path)
                .join("SimpleExpr.rec_686e510a6699f2e1ff1b216c16d94cd379ebeca00c030a79a3134adff699e06c.json");

            let mut file = File::open(&file_path)
                .map_err(|e| Box::new(e) as ThreadSafeError)?;
            let mut json_str = String::new();
            file.read_to_string(&mut json_str)
                .map_err(|e| Box::new(e) as ThreadSafeError)?;

            let initial_json_value: Value = serde_json::from_str(&json_str)
                .map_err(|e| Box::new(e) as ThreadSafeError)?;

            let mut current_json_value = initial_json_value;

            let mut prime_morphism = PrimeMorphism::new(HashMap::new()); // Initialize with an empty char_to_prime map

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

            let mut master_prime_vector = PrimeVector::new();
            let mut schema_matrix_opt: Option<SchemaMatrix> = None;
            let mut eigenvalues_opt: Option<Vec<Complex<f64>>> = None;
            let mut eigenvectors_opt: Option<Vec<DVector<Complex<f64>>>> = None;


            if let Some(schema) = final_schema {
                traverse_schema_node_for_prime_vector(&schema.root, &mut prime_morphism, &mut master_prime_vector);
                
                // Create SchemaMatrix from the final schema
                // This requires converting the SchemaNode tree back to a HashMap<String, JsonType> or similar path-based structure
                // for SchemaMatrix::from_schema to work as currently designed.
                // For now, let's simplify and make a flat list of paths from the final schema tree.
                let mut final_schema_paths = HashMap::new();
                let mut path_stack = vec![("".to_string(), &schema.root)];

                while let Some((current_path_str, current_node)) = path_stack.pop() {
                    // Only add path if it's not the root itself (empty string)
                    if !current_path_str.is_empty() {
                        // The `json_type` field might not be directly clonable or its type could be JsonType.
                        // Assuming JsonType is clonable, which it is now.
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
                
                // Perform eigenvalue decomposition
                let size = sm.matrix.len();
                if size > 0 {
                    let mut data = Vec::with_capacity(size * size);
                    for row in &sm.matrix {
                        for &val in row {
                            data.push(val as f64);
                        }
                    }
                    let dmatrix = DMatrix::from_vec(size, size, data);

                    let eigen = dmatrix.symmetric_eigen(); // Using symmetric_eigen for real symmetric matrices
                                                           // For general matrices, use .eigenvalues() and .eigenvectors()
                                                           // However, nalgebra's general eigenvalue decomposition is currently
                                                           // limited to square matrices whose elements are real.
                                                           // Our matrix is real, but not necessarily symmetric.
                                                           // For a general real matrix, we would use:
                                                           // let eigen = nalgebra::linalg::Eigen::new(dmatrix.clone());
                                                           // but this only computes eigenvalues for matrices where the eigenvalues are real.
                                                           // For complex eigenvalues, one needs a different decomposition.
                                                           // Let's just use the `Eigen` decomposition directly, which returns real eigenvalues for real matrices (if they exist).
                                                           // If the matrix is not symmetric, eigenvalues can be complex.
                                                           // The Eigen::new() function returns an Option.

                    // Check if the matrix is symmetric to use symmetric_eigen
                    let is_symmetric = dmatrix.transpose() == dmatrix;
                    if is_symmetric {
                        let symmetric_eigen_decomposition = dmatrix.symmetric_eigen(); // Correctly get the SymmetricEigen struct
                        let eigen_values_real = symmetric_eigen_decomposition.eigenvalues;
                        let eigen_vectors_real = symmetric_eigen_decomposition.eigenvectors;
                        
                        eigenvalues_opt = Some(eigen_values_real.into_iter().map(|&v| Complex::new(v, 0.0)).collect()); // Corrected type conversion
                        eigenvectors_opt = Some(eigen_vectors_real.column_iter().map(|c| c.map(|&v| Complex::new(*v, 0.0))).collect()); // Corrected type conversion
                    } else {
                        // For non-symmetric real matrices, which may have complex eigenvalues.
                        // We use `nalgebra::linalg::Eigen` to attempt to get the eigenvalues and eigenvectors.
                        // `Eigen::new` handles both real and complex eigenvalues for real matrices.
                        if let Some(eigen_decomposition) = nalgebra::linalg::Eigen::new(dmatrix.clone()) {
                            // Eigenvalues are already Complex
                            eigenvalues_opt = Some(eigen_decomposition.eigenvalues.iter().cloned().collect());
                            // Eigenvectors are also Complex DMatrix
                            eigenvectors_opt = Some(eigen_decomposition.eigenvectors.column_iter().map(|c| c.clone_owned()).collect());
                        } else {
                             // Handle case where Eigen decomposition doesn't return (e.g. non-invertible matrix, or other numerical issues)
                            // For simplicity, we'll leave eigenvalues_opt and eigenvectors_opt as None.
                            eprintln!("Warning: Eigen decomposition failed for the schema matrix.");
                        }
                    }
                }
                schema_matrix_opt = Some(sm);
            }

            // Save the report to a JSON file
            let report = Report {
                iterations: all_iteration_reports,
                master_prime_vector: master_prime_vector.map,
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
        })?; // Handle Box<dyn Any + Send> from join

    thread_result // Return the Result<(), ThreadSafeError> from the child thread
}
