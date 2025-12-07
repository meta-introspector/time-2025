use nalgebra::{DMatrix};
use monster_svg_morphism::{code_parser::{collect_declarations_from_dir}, types::prime_vector::PrimeMorphism};
use std::path::Path;

/// Calculates the dot product of two PrimeVectors.
/// This measures their similarity based on common primes and their coefficients.
fn prime_vector_dot_product(pv1: &monster_svg_morphism::types::prime_vector::PrimeVector, pv2: &monster_svg_morphism::types::prime_vector::PrimeVector) -> f64 {
    let mut dot_product = 0.0;
    for (prime, coeff1) in &pv1.map {
        if let Some(coeff2) = pv2.map.get(prime) {
            dot_product += (*coeff1 as f64) * (*coeff2 as f64);
        }
    }
    dot_product
}

/// Prints a summary of the matrix, including sum, zero percentage, and an 80-character visual representation.
fn print_matrix_summary(matrix: &DMatrix<f64>, iteration: usize) {
    println!("\n--- Summary for Iteration {} (Matrix M^{}) ---", iteration, iteration);

    let total_sum = matrix.sum();
    println!("Total Sum: {:.2}", total_sum);

    let non_zero_count = matrix.iter().filter(|&x| x.abs() > f64::EPSILON).count();
    let total_cells = matrix.len();
    let zero_percentage = if total_cells > 0 {
        (1.0 - (non_zero_count as f64 / total_cells as f64)) * 100.0
    } else {
        0.0
    };
    println!("Zero Percentage: {:.2}%", zero_percentage);

    // 80-character visual summary
    let num_cols = matrix.ncols();
    let num_rows = matrix.nrows();
    
    if num_cols > 0 && num_rows > 0 {
        let mut summarized_values = Vec::with_capacity(80);
        let mut max_val = 0.0;

        for i in 0..80 {
            let start_col_idx = (i * num_cols) / 80;
            let end_col_idx = ((i + 1) * num_cols) / 80;
            
            // Ensure end_col_idx doesn't exceed num_cols (can happen if num_cols < 80)
            let end_col_idx = end_col_idx.min(num_cols);

            if start_col_idx >= end_col_idx {
                summarized_values.push(0.0);
                continue;
            }

            let mut section_sum = 0.0;
            let mut section_count = 0;

            for r in 0..num_rows {
                for c in start_col_idx..end_col_idx {
                    section_sum += matrix[(r, c)];
                    section_count += 1;
                }
            }
            let avg = if section_count > 0 { section_sum / section_count as f64 } else { 0.0 };
            summarized_values.push(avg);
            if avg > max_val {
                max_val = avg;
            }
        }

        print!("Visual (80 chars): ");
        if max_val > f64::EPSILON {
            let chars = " .:-=+*#%@"; // 10 intensity levels
            for &val in &summarized_values {
                let scaled_val = (val / max_val) * (chars.len() - 1) as f64;
                let char_idx = scaled_val.round() as usize;
                print!("{}", chars.chars().nth(char_idx).unwrap_or(' '));
            }
        } else {
            // All zeros or near zero
            print!("{}", "_".repeat(80));
        }
        println!();
    }
}


fn main() {
    println!("Starting analysis for building a substantial matrix from code declarations.");

    // 1. Collect declarations from the current crate
    let crate_path = Path::new(".").canonicalize().expect("Failed to canonicalize path");
    let declarations = collect_declarations_from_dir(&crate_path);

    if declarations.is_empty() {
        println!("No declarations found in the crate. Exiting.");
        return;
    }

    println!("\nFound {} declarations:", declarations.len());
    // for decl in &declarations {
    //     println!("  Type: {{}}, Path: {{}}", decl.decl_type, decl.full_path);
    // }

    // 2. Generate PrimeVectors for each declaration
    let mut prime_morphism = PrimeMorphism::new();
    let mut declaration_prime_vectors = Vec::new();
    
    for decl in &declarations {
        let path_segments: Vec<String> = decl.full_path.split("::").map(|s| s.to_string()).collect();
        let prime_vector = prime_morphism.path_to_prime_vector(&path_segments);
        declaration_prime_vectors.push(prime_vector);
    }

    let num_declarations = declarations.len();
    
    // 3. Construct the Substantial Square Matrix (Declaration x Declaration) similarity
    let matrix_dim = num_declarations; // Matrix dimension is simply the number of declarations
    let mut substantial_matrix = DMatrix::<f64>::zeros(matrix_dim, matrix_dim);

    println!("\nBuilding a {}x{} substantial (Declaration x Declaration) matrix...", matrix_dim, matrix_dim);

    for i in 0..num_declarations {
        for j in 0..num_declarations {
            let dot_product = prime_vector_dot_product(
                &declaration_prime_vectors[i],
                &declaration_prime_vectors[j],
            );
            substantial_matrix[(i, j)] = dot_product;
        }
    }

    // 4. Perform iterative multiplication
    println!("\nStarting iterative matrix multiplication.");

    let mut current_matrix = substantial_matrix.clone(); // Start with M^1

    // Print M^1 summary
    print_matrix_summary(&current_matrix, 1);

    let num_iterations = 5;
    for i in 2..=num_iterations {
        // M^k = M^(k-1) * M
        current_matrix = &current_matrix * &substantial_matrix;
        print_matrix_summary(&current_matrix, i);
    }

    println!("\nIterative matrix multiplication complete.");
}
