// lean_introspector/src/driver_factory.rs
// use crate::decomposition::DecompositionAdaptor;
// use ndarray::{Array1, Array2};
// use num_complex::Complex;

// // Conditionally import backends
// #[cfg(feature = "nalgebra-backend")]
// use crate::nalgebra_backend::NalgebraBackend;
// #[cfg(feature = "linfa-backend")] // Added cfg for libfaalg_backend
// use crate::libfaalg_backend::LibfaalgBackend;
// use crate::octave_backend::OctaveBackend; // Octave is always available

// pub enum DecompositionDriver {
//     #[cfg(feature = "nalgebra-backend")]
//     Nalgebra(NalgebraBackend),
//     #[cfg(feature = "linfa-backend")] // Added cfg for Libfaalg variant
//     Libfaalg(LibfaalgBackend),
//     Octave(OctaveBackend),
// }

// impl DecompositionAdaptor for DecompositionDriver {
//     fn eigen_decompose(&self, matrix: &Array2<f64>) -> Option<(Vec<Complex<f64>>, Vec<Array1<Complex<f64>>>)> {
//         match self {
//             #[cfg(feature = "nalgebra-backend")]
//             DecompositionDriver::Nalgebra(backend) => backend.eigen_decompose(matrix),
//             #[cfg(feature = "linfa-backend")] // Added cfg for Libfaalg match arm
//             DecompositionDriver::Libfaalg(backend) => backend.eigen_decompose(matrix),
//             DecompositionDriver::Octave(backend) => backend.eigen_decompose(matrix),
//         }
//     }
// }

// pub fn get_decomposition_driver(backend_name: &str) -> Result<DecompositionDriver, String> {
//     match backend_name {
//         #[cfg(feature = "nalgebra-backend")]
//         "nalgebra" => Ok(DecompositionDriver::Nalgebra(NalgebraBackend)),
//         #[cfg(feature = "linfa-backend")] // Added cfg for libfaalg case
//         "libfaalg" => Ok(DecompositionDriver::Libfaalg(LibfaalgBackend)),
//         "octave" => Ok(DecompositionDriver::Octave(OctaveBackend)),
//         _ => Err(format!("Unknown decomposition backend: {}", backend_name)),
//     }
// }