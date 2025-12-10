// lean_introspector/src/octave_backend.rs
use crate::decomposition::DecompositionAdaptor;
use ndarray::{Array1, Array2};
use num_complex::Complex;
use std::io::Write;
use std::process::Command;
use std::fs;
use std::path::Path;

pub struct OctaveBackend;

impl DecompositionAdaptor for OctaveBackend {
    fn eigen_decompose(&self, matrix: &Array2<f64>) -> Option<(Vec<Complex<f64>>, Vec<Array1<Complex<f64>>>)> {
        let size = matrix.nrows();
        if matrix.ncols() != size {
            eprintln!("Error: Octave backend requires a square matrix.");
            return None;
        }

        let input_file_path = Path::new("octave_input.txt");
        let output_file_path = Path::new("octave_output.txt");
        let octave_script_path = Path::new("./octave_scripts/eigen_script.m");

        // 1. Write matrix to input file
        let mut input_file = fs::File::create(input_file_path)
            .map_err(|e| { eprintln!("Error creating Octave input file: {}", e); e })
            .ok()?;
        for row in matrix.rows() {
            let row_str: Vec<String> = row.iter().map(|&x| x.to_string()).collect();
            writeln!(input_file, "{}", row_str.join(" "))
                .map_err(|e| { eprintln!("Error writing to Octave input file: {}", e); e })
                .ok()?;
        }

        // 2. Execute Octave script
        let output = Command::new("octave-cli") // Use octave-cli for non-interactive execution
            .arg("--eval")
            .arg(format!(
                "run('{}'); eigen_script('{}', '{}')",
                octave_script_path.display(),
                input_file_path.display(),
                output_file_path.display()
            ))
            .output()
            .map_err(|e| { eprintln!("Error executing Octave: {}", e); e })
            .ok()?;

        if !output.status.success() {
            eprintln!("Octave command failed: {:?}", output.status);
            eprintln!("Stdout: {}", String::from_utf8_lossy(&output.stdout));
            eprintln!("Stderr: {}", String::from_utf8_lossy(&output.stderr));
            return None;
        }

        // 3. Read results from output file
        let output_content = fs::read_to_string(output_file_path)
            .map_err(|e| { eprintln!("Error reading Octave output file: {}", e); e })
            .ok()?;

        // Example parsing: (assuming format is EIGENVALUES then EIGENVECTORS)
        // EIGENVALUES:
        // re1 im1
        // re2 im2
        // ...
        // EIGENVECTORS:
        // re11 im11 re12 im12 ...
        // re21 im21 re22 im22 ...
        let mut eigenvalues = Vec::new();
        let mut eigenvectors_raw = Vec::new();
        let mut parsing_eigenvalues = false;
        let mut parsing_eigenvectors = false;

        for line in output_content.lines() {
            if line.trim() == "EIGENVALUES:" {
                parsing_eigenvalues = true;
                parsing_eigenvectors = false;
                continue;
            }
            if line.trim() == "EIGENVECTORS:" {
                parsing_eigenvalues = false;
                parsing_eigenvectors = true;
                continue;
            }

            if parsing_eigenvalues {
                let parts: Vec<&str> = line.split_whitespace().collect();
                if parts.len() == 2 {
                    if let (Ok(re), Ok(im)) = (parts[0].parse(), parts[1].parse()) {
                        eigenvalues.push(Complex::new(re, im));
                    }
                }
            } else if parsing_eigenvectors {
                let parts: Vec<&str> = line.split_whitespace().collect();
                let mut row_complex = Vec::new();
                for chunk in parts.chunks(2) {
                    if chunk.len() == 2 {
                        if let (Ok(re), Ok(im)) = (chunk[0].parse(), chunk[1].parse()) {
                            row_complex.push(Complex::new(re, im));
                        }
                    }
                }
                if !row_complex.is_empty() {
                    eigenvectors_raw.push(row_complex);
                }
            }
        }

        // Convert raw eigenvectors to Vec<Array1<Complex<f64>>>
        let mut eigenvectors: Vec<Array1<Complex<f64>>> = Vec::new();
        if !eigenvectors_raw.is_empty() && !eigenvectors_raw[0].is_empty() {
            // Octave returns eigenvectors as columns, so we need to transpose
            // if eigenvectors_raw is row-major. Let's assume eigenvectors_raw
            // here is matrix of (rows, cols) where each row is a vector from octave.
            // If octave outputs in column-major, then this parsing might be different.
            // Assuming octave outputs each eigenvector as a row or we parse it as such:
            // if eigenvectors_raw[0] is one eigenvector, then convert it.
            // But if each row in eigenvectors_raw is actually a row of the eigenvector matrix,
            // then we need to extract columns.
            // Let's assume Octave's eig() returns V where columns are eigenvectors.
            // My parsing currently reads rows from the output. So if each line is a row of V^T
            // Then I need to reconstruct.
            
            let num_vectors = eigenvectors_raw[0].len(); // Number of eigenvectors
            let vector_dim = eigenvectors_raw.len(); // Dimension of each vector

            for j in 0..num_vectors {
                let mut current_eigenvector = Vec::with_capacity(vector_dim);
                for i in 0..vector_dim {
                    current_eigenvector.push(eigenvectors_raw[i][j]);
                }
                eigenvectors.push(Array1::from_vec(current_eigenvector));
            }
        }
        
        // Clean up temporary files
        let _ = fs::remove_file(input_file_path);
        let _ = fs::remove_file(output_file_path);

        Some((eigenvalues, eigenvectors))
    }
}
