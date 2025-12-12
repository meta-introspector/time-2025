use std::collections::HashMap;
use monster_svg_morphism::analysis_report::AnalysisReport;
use svg_hir::prime_vector::{PrimeVector};
use serde_json;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    eprintln!("DEBUG: Starting minimal serialization test.");

    // 1. Construct a dummy AnalysisReport
    let dummy_prime_vector = PrimeVector {
        map: HashMap::from([
            (2, 1),
            (3, 2),
            (5, 1),
        ]),
    };

    let dummy_composite_prime_vector = PrimeVector {
        map: HashMap::from([
            (7, 1),
            (11, 2),
            (13, 1),
        ]),
    };

    let mut dummy_symbol_table = HashMap::new();
    dummy_symbol_table.insert("crate::dummy_fn".to_string(), dummy_prime_vector.clone());
    dummy_symbol_table.insert("crate::dummy_struct".to_string(), dummy_prime_vector.clone());

    let mut dummy_composite_prime_vectors = HashMap::new();
    dummy_composite_prime_vectors.insert("crate::composite".to_string(), dummy_composite_prime_vector.clone());


    let dummy_report = AnalysisReport {
        prime_occurrences: HashMap::from([
            (0, vec!["Dummy occurrence 1".to_string(), "Dummy occurrence 2".to_string()]),
            (13, vec!["Dummy length 13".to_string()]),
        ]),
        prime_factor_occurrences: HashMap::from([
            (2, vec!["Dummy factor 2".to_string()]),
            (3, vec!["Dummy factor 3".to_string()]),
        ]),
        recursive_functions: vec!["dummy_recursive_fn".to_string()],
        recursive_cycles: vec![("dummy_caller".to_string(), vec!["dummy_callee".to_string()])],
        symbol_table: dummy_symbol_table,
        symbol_matrix: vec![vec![1, 2, 3], vec![4, 5, 6]],
        matrix_column_headers: vec![2, 3, 5],
        matrix_row_headers: vec!["row1".to_string(), "row2".to_string()],
        composite_prime_vectors: dummy_composite_prime_vectors,
        char_pair_transitions: HashMap::from([(('a', 'b'), 1), (('c', 'd'), 2)]),
        ngrams_frequencies: HashMap::from([(3, HashMap::from([("foo".to_string(), 1), ("bar".to_string(), 2)]))]),
        substring_prime_vectors: HashMap::from([("sub1".to_string(), dummy_prime_vector.clone())]),
    };

    eprintln!("DEBUG: Dummy AnalysisReport constructed: {:?}", dummy_report);

    // 2. Call serde_json::to_vec() on this dummy AnalysisReport.
    eprintln!("DEBUG: Attempting to serialize report...");
    let serialized_report = match serde_json::to_vec(&dummy_report) {
        Ok(bytes) => {
            eprintln!("DEBUG: Serialization successful!");
            bytes
        },
        Err(e) => {
            eprintln!("ERROR: Serialization failed: {}", e);
            return Err(e.into());
        }
    };

    // 3. Print the serialized_report (length and content).
    eprintln!("DEBUG: Serialized report size: {} bytes", serialized_report.len());
    let display_len = std::cmp::min(serialized_report.len(), 500); // Print up to 500 bytes
    eprintln!("DEBUG: Serialized report (first {} bytes): {:?}", display_len, &serialized_report[..display_len]);
    eprintln!("DEBUG: Serialized report (as string, if valid UTF-8): {:?}", String::from_utf8_lossy(&serialized_report));


    // 4. Attempt to serde_json::from_slice() on the serialized bytes.
    eprintln!("DEBUG: Attempting to deserialize report...");
    let deserialized_report: AnalysisReport = match serde_json::from_slice(&serialized_report) {
        Ok(report) => {
            eprintln!("DEBUG: Deserialization successful!");
            report
        },
        Err(e) => {
            eprintln!("ERROR: Deserialization failed: {}", e);
            return Err(e.into());
        }
    };

    eprintln!("DEBUG: Deserialized report: {:?}", deserialized_report);

    // 5. Verify integrity (optional, but good practice)
    assert_eq!(dummy_report.prime_occurrences.len(), deserialized_report.prime_occurrences.len());
    assert_eq!(dummy_report.recursive_functions, deserialized_report.recursive_functions);

    eprintln!("DEBUG: Minimal serialization test completed successfully.");

    Ok(())
}
