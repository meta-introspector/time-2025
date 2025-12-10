// nalgebra_adaptor/src/lib.rs
use nalgebra::{DMatrix, Complex, DVector};
//use nalgebra_lapack::Eigen; // New import

// Define a trait for linear algebra operations
pub trait LinearAlgebraAdaptor {
    // Function to create a DMatrix from raw data
    fn create_dmatrix(rows: usize, cols: usize, data: Vec<f64>) -> DMatrix<f64>;

    // Function to perform eigenvalue decomposition on a DMatrix
    // Returns (eigenvalues, eigenvectors)
    fn eigen_decompose(matrix: &DMatrix<f64>) -> Option<(Vec<Complex<f64>>, Vec<DVector<Complex<f64>>>)>;
}

// Implement the trait for Nalgebra (or a dummy struct for Nalgebra)
pub struct NalgebraAdaptor;

impl LinearAlgebraAdaptor for NalgebraAdaptor {
    fn create_dmatrix(rows: usize, cols: usize, data: Vec<f64>) -> DMatrix<f64> {
        DMatrix::from_vec(rows, cols, data)
    }

    fn eigen_decompose(matrix: &DMatrix<f64>) -> Option<(Vec<Complex<f64>>, Vec<DVector<Complex<f64>>>)> {
        let is_symmetric = matrix.transpose() == *matrix;
        let size = matrix.nrows();

        if size == 0 {
            return Some((Vec::new(), Vec::new()));
        }

        if is_symmetric {
            let symmetric_eigen_decomposition = matrix.clone().symmetric_eigen();
            let eigen_values_real = symmetric_eigen_decomposition.eigenvalues;
            let eigen_vectors_real = symmetric_eigen_decomposition.eigenvectors;

            let eigenvalues = eigen_values_real.iter().map(|&v| Complex::new(v, 0.0)).collect();
            let eigenvectors = eigen_vectors_real.column_iter().map(|c| c.map(|v| Complex::new(v, 0.0))).collect();
            Some((eigenvalues, eigenvectors))
        } else {
            // // Use nalgebra_lapack::Eigen for general (non-symmetric) matrices
            // let eigen_decomposition = Eigen::new(matrix.clone(), false, true)?; // false for left_eigenvectors, true for eigenvectors
            
            // let eigenvalues: Vec<Complex<f64>> = eigen_decomposition.eigenvalues_re.iter().zip(eigen_decomposition.eigenvalues_im.iter())
            //                                         .map(|(&re, &im)| Complex::new(re, im))
            //                                         .collect();
            // let eigenvectors: Vec<DVector<Complex<f64>>> = eigen_decomposition.eigenvectors.expect("Eigenvectors should be computed").column_iter().map(|c| c.map(|v| Complex::new(v, 0.0))).collect();
            
            // Some((eigenvalues, eigenvectors))
            None // Return None for non-symmetric matrices if nalgebra-lapack is disabled
        }
    }
}