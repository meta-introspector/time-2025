use ndarray::{Array1, Array2};
use linfa_linalg::qr::QR;
use crate::types::MonsterElementKind;

const PRIMES: [u64; 15] = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 41, 47, 59, 71];

/// Exposes the prime factors of the Monster Group's order.
pub fn get_primes() -> &'static [u64] {
    &PRIMES
}

// This order must match the order of PRIMES
const MONSTER_ELEMENTS: [MonsterElementKind; 15] = [
    MonsterElementKind::P2_46,
    MonsterElementKind::P3_20,
    MonsterElementKind::P5_9,
    MonsterElementKind::P7_6,
    MonsterElementKind::P11_2,
    MonsterElementKind::P13_3,
    MonsterElementKind::P17_1,
    MonsterElementKind::P19_1,
    MonsterElementKind::P23_1,
    MonsterElementKind::P29_1,
    MonsterElementKind::P31_1,
    MonsterElementKind::P41_1,
    MonsterElementKind::P47_1,
    MonsterElementKind::P59_1,
    MonsterElementKind::P71_1,
];

/// Exposes the MonsterElementKind mapping to the prime factors.
pub fn get_monster_elements() -> &'static [MonsterElementKind] {
    &MONSTER_ELEMENTS
}

pub fn construct_monster_matrix() -> Array2<f64> {
    let exponents = [46, 20, 9, 6, 2, 3, 1, 1, 1, 1, 1, 1, 1, 1, 1];
    let mut matrix = Array2::<f64>::zeros((15, 15));
    for i in 0..15 {
        matrix[(i, i)] = exponents[i] as f64;
    }
    matrix
}

pub fn analyze_monster_order() -> Array1<f64> {
    let monster_order_exponents = Array1::from_vec(vec![
        46.0, 20.0, 9.0, 6.0, 2.0, 3.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
    ]);

    let monster_matrix = construct_monster_matrix();
    let inverse_monster_matrix = monster_matrix.qr().unwrap().inverse().unwrap();

    // The user mentioned division, which I interpret as multiplication by the inverse.
    // To treat monster_order_exponents as a row vector, we would do monster_order_exponents.transpose() * inverse_monster_matrix
    // However, nalgebra's matrix multiplication is set up for M * v, so we'll do inverse_monster_matrix * monster_order_exponents.
    // This will produce a column vector of the results.
    inverse_monster_matrix.dot(&monster_order_exponents)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_analyze_monster_order() {
        let result = analyze_monster_order();
        let expected = Array1::from_vec(vec![
            1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0,
        ]);
        assert_eq!(result, expected);
    }
}