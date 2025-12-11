use std::collections::HashMap;
use serde::{Serialize, Deserialize};
use svg_hir::prime_vector::PrimeVector;

#[derive(Debug, Serialize, Deserialize)]
pub struct AnalysisReport {
    pub prime_occurrences: HashMap<u64, Vec<String>>,
    pub prime_factor_occurrences: HashMap<u64, Vec<String>>,
    pub recursive_functions: Vec<String>,
    pub recursive_cycles: Vec<(String, Vec<String>)>,
    pub symbol_table: HashMap<String, PrimeVector>,
    pub symbol_matrix: Vec<Vec<u64>>,
    pub matrix_column_headers: Vec<u64>,
    pub matrix_row_headers: Vec<String>,
    pub composite_prime_vectors: HashMap<String, PrimeVector>,
    pub char_pair_transitions: HashMap<(char, char), usize>,
    pub ngrams_frequencies: HashMap<usize, HashMap<String, usize>>,
    pub substring_prime_vectors: HashMap<String, PrimeVector>,
}