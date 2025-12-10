// lean_introspector/src/nalgebra_backend.rs
// #[cfg(feature = "nalgebra-backend")]
// use nalgebra_adaptor::LinearAlgebraAdaptor;
// #[cfg(feature = "nalgebra-backend")]
// use nalgebra_adaptor::NalgebraAdaptor;
// #[cfg(feature = "nalgebra-backend")]
// use ndarray::{Array1, Array2};
// #[cfg(feature = "nalgebra-backend")]
// use num_complex::Complex;
// #[cfg(feature = "nalgebra-backend")]
// use crate::decomposition::DecompositionAdaptor;

// #[cfg(feature = "nalgebra-backend")]
// pub struct NalgebraBackend;

// #[cfg(feature = "nalgebra-backend")]
// impl DecompositionAdaptor for NalgebraBackend {
//     fn eigen_decompose(&self, matrix: &Array2<f64>) -> Option<(Vec<Complex<f64>>, Vec<Array1<Complex<f64>>>)> {
//         let rows = matrix.nrows();
//         let cols = matrix.ncols();
//         let data: Vec<f64> = matrix.iter().cloned().collect();

//         // Use the NalgebraAdaptor to perform the decomposition
//         let (eigenvalues_vec, eigenvectors_dvectors) = NalgebraAdaptor::eigen_decompose(&NalgebraAdaptor::create_dmatrix(rows, cols, data))?;
        
//         let eigenvalues = eigenvalues_vec;
//         let eigenvectors = eigenvectors_dvectors.into_iter()
//                                                 .map(|dvector| Array1::from_vec(dvector.as_slice().to_vec()))
//                                                 .collect();
//         Some((eigenvalues, eigenvectors))
//     }
// }