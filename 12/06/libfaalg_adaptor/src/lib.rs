use ndarray::prelude::{Array1, Array2};
use linfa_linalg::eigh::EighInto;
use num_complex::Complex;

pub trait LinearAlgebraAdaptor {
    fn create_dmatrix(rows: usize, cols: usize, data: Vec<f64>) -> Array2<f64>;
    fn eigen_decompose(matrix: &Array2<f64>) -> Option<(Vec<Complex<f64>>, Vec<Array1<Complex<f64>>>)>;
}

pub struct LibfaalgAdaptor;

impl LinearAlgebraAdaptor for LibfaalgAdaptor {
    fn create_dmatrix(rows: usize, cols: usize, data: Vec<f64>) -> Array2<f64> {
        Array2::from_shape_vec((rows, cols), data).expect("Failed to create Array2 from data")
    }

    fn eigen_decompose(matrix: &Array2<f64>) -> Option<(Vec<Complex<f64>>, Vec<Array1<Complex<f64>>>)> {
        if matrix.t() != *matrix {
            return None;
        }

        let (eigenvalues, eigenvectors) = linfa_linalg::eigh::EighInto::eigh_into(matrix.to_owned()).ok()?;

        let eigenvalues_complex: Vec<Complex<f64>> = eigenvalues.iter().map(|&v| Complex::new(v, 0.0)).collect();

        let eigenvectors_complex: Vec<Array1<Complex<f64>>> = eigenvectors
            .columns()
            .into_iter()
            .map(|col| {
                col.map(|&v| Complex::new(v, 0.0)).to_owned()
            })
            .collect();
        
        Some((eigenvalues_complex, eigenvectors_complex))
    }
}