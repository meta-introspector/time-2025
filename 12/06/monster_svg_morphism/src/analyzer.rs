use std::collections::HashMap;
use std::fs;
use std::path::{Path, PathBuf};
use walkdir::WalkDir;
use syn::File;
use svg_hir::prime_vector::{PrimeMorphism, PrimeGenerator};
use crate::analysis_report::AnalysisReport;
use crate::char_frequency::CharFrequencyAnalyzer;
use crate::char_sequence::CharacterSequenceAnalyzer;
use crate::ast_visitor::AnalysisVisitor;
use crate::cycle_detection::find_cycles_dfs;
use crate::code_parser::{collect_code_elements_from_dir};
use svg_hir::keys;


pub fn run_analysis(path: &PathBuf, primes_to_analyze: &[u64]) -> AnalysisReport {
    let mut char_freq_analyzer = CharFrequencyAnalyzer::new();
    char_freq_analyzer.collect_char_frequencies(path);
    let char_to_prime_map = char_freq_analyzer.generate_char_to_prime_map();

    let mut visitor = AnalysisVisitor {
        prime_occurrences: HashMap::new(),
        prime_factor_occurrences: HashMap::new(),
        recursive_functions: Vec::new(),
        current_function: None,
        function_calls: HashMap::new(),
        primes_to_analyze,
        current_path: vec!["crate".to_string()], // Initialize with "crate" as the root
        prime_morphism: PrimeMorphism::new(char_to_prime_map), // Initialize PrimeMorphism with the new map
        symbol_table: HashMap::new(), // Initialize symbol_table
    };

    let all_code_elements = collect_code_elements_from_dir(path);
    // Collect identifiers for CharacterSequenceAnalyzer
    let mut identifiers_for_sequence_analysis = Vec::new();
    for element in &all_code_elements {
        identifiers_for_sequence_analysis.push(element.name.clone());
        for ident in &element.associated_idents {
            identifiers_for_sequence_analysis.push(ident.clone());
        }
    }

    let mut char_sequence_analyzer = CharacterSequenceAnalyzer::new();
    char_sequence_analyzer.collect_from_identifiers(&identifiers_for_sequence_analysis);

    for entry in WalkDir::new(path)
        .into_iter()
        .filter_map(|e| e.ok())
        .filter(|e| e.path().extension().map_or(false, |s| s == "rs"))
    {
        let file_path = entry.path(); // Renamed to avoid shadowing
        let content = match fs::read_to_string(file_path) {
            Ok(c) => c,
            Err(_) => continue,
        };

        let ast: File = match syn::parse_file(&content) {
            Ok(a) => a,
            Err(e) => {
                eprintln!("Error parsing file {}: {}", file_path.display(), e); // Use file_path here
                continue;
            }
        };

        visitor.visit_file(&ast);
    }

    // After visiting all files, analyze for direct recursion
    // (This part remains for compatibility, but cycles will cover it)
    for (caller, callees) in &visitor.function_calls {
        if callees.contains(caller) {
            visitor.recursive_functions.push(caller.clone());
        }
    }

    // --- Cycle Detection for Indirect Recursion ---
    let mut all_recursive_cycles: Vec<(String, Vec<String>)> = Vec::new();
    let mut visited: HashMap<String, bool> = HashMap::new();
    let mut recursion_stack: HashMap<String, bool> = HashMap::new();
    let mut path_vec: Vec<String> = Vec::new(); // Renamed to avoid shadowing

    for function_name in visitor.function_calls.keys() {
        if !visited.get(function_name).unwrap_or(&false) {
            find_cycles_dfs(
                &visitor.function_calls,
                function_name,
                &mut visited,
                &mut recursion_stack,
                &mut path_vec, // Use renamed variable
                &mut all_recursive_cycles,
                primes_to_analyze,
            );
        }
    }
    
    let mut final_symbol_table = visitor.symbol_table; // Get the populated symbol table from the visitor
    let crate_root_path = "crate".to_string();
    let mut crate_root_vector = visitor.prime_morphism.path_to_prime_vector(&visitor.current_path); // Base vector for crate root

    // Check if it's a Rust crate (has Cargo.toml)
    if path.join("Cargo.toml").exists() {
        crate_root_vector.map.insert(visitor.prime_morphism.get_prime_for_component(keys::PREDICATE_IS_CRATE), 1);
    }
    // Check if it's an executable crate (main.rs exists)
    if path.join("src").join("main.rs").exists() {
        crate_root_vector.map.insert(visitor.prime_morphism.get_prime_for_component(keys::PREDICATE_IS_EXE), 1);
    }
    // Check for Nix flake (flake.nix exists)
    if path.join("flake.nix").exists() {
        crate_root_vector.map.insert(visitor.prime_morphism.get_prime_for_component(keys::PREDICATE_IS_NIX_FLAKE), 1);
    }
    // Check for Git repository (.git directory exists)
    if path.join(".git").exists() {
        crate_root_vector.map.insert(visitor.prime_morphism.get_prime_for_component(keys::PREDICATE_IS_GIT_REPOSITORY), 1);
        // Check if on an active Git branch (not detached HEAD)
        // For now, a simpler heuristic: if .git/HEAD contains "ref: refs/heads/", it's probably on a branch.
        if let Ok(head_content) = std::fs::read_to_string(path.join(".git").join("HEAD")) {
            if head_content.starts_with("ref: refs/heads/") {
                crate_root_vector.map.insert(visitor.prime_morphism.get_prime_for_component(keys::PREDICATE_IS_GIT_BRANCH_ACTIVE), 1);
            }
        }
    }
    
    final_symbol_table.insert(crate_root_path, crate_root_vector);

    // --- Conceptual Matrix Self-Multiplication: Aggregating PrimeVectors for related nodes ---
    let mut composite_prime_vectors: HashMap<String, PrimeVector> = HashMap::new();

    // Iterate through symbols, sorted for deterministic aggregation
    let mut all_symbol_paths: Vec<String> = final_symbol_table.keys().cloned().collect();
    all_symbol_paths.sort_unstable(); // Sort to ensure consistent processing order

    for symbol_path in &all_symbol_paths {
        if symbol_path == "crate" {
            // "crate" is the root; its PrimeVector is already computed.
            // We can optionally "multiply" all top-level modules into it later if desired.
            continue;
        }

        let parts: Vec<&str> = symbol_path.split("::").collect();
        if parts.len() < 2 {
            // Not a nested symbol (e.g., "crate" handled above, or malformed path)
            continue;
        }

        // Reconstruct parent path
        let parent_path = parts[0..(parts.len() - 1)].join("::");

        if let Some(child_prime_vector) = final_symbol_table.get(symbol_path) {
            let parent_composite_vector = composite_prime_vectors
                .entry(parent_path.clone())
                .or_insert_with(PrimeVector::new);
            
            // "Multiply" (add coefficients) the child's prime vector into the parent's composite
            parent_composite_vector.multiply(child_prime_vector);
        }
    }

    // Include the composite_prime_vectors in the final symbol_table as well,
    // or keep them separate. For now, let's keep them separate as defined in AnalysisReport.

    // --- Flatten symbol_table into matrix views ---
    let mut all_unique_primes: Vec<u64> = Vec::new();
    for prime_vector in final_symbol_table.values() {
        for &prime in prime_vector.map.keys() {
            if !all_unique_primes.contains(&prime) {
                all_unique_primes.push(prime);
            }
        }
    }
    all_unique_primes.sort_unstable(); // Sort primes to ensure consistent column order

    let mut symbol_matrix: Vec<Vec<u64>> = Vec::new();
    let mut matrix_row_headers: Vec<String> = Vec::new();

    // Collect symbols and sort them for consistent row order
    let mut sorted_symbol_names: Vec<String> = final_symbol_table.keys().cloned().collect();
    sorted_symbol_names.sort_unstable();

    for symbol_name in sorted_symbol_names {
        if let Some(prime_vector) = final_symbol_table.get(&symbol_name) {
            let mut row: Vec<u64> = Vec::with_capacity(all_unique_primes.len());
            for &prime_col_header in &all_unique_primes {
                row.push(*prime_vector.map.get(&prime_col_header).unwrap_or(&0));
            }
            symbol_matrix.push(row);
            matrix_row_headers.push(symbol_name.clone());
        }
    }

    // --- Collect substring PrimeVectors ---
    let mut substring_prime_vectors = HashMap::new();
    for (_n_val, ngrams_map) in &char_sequence_analyzer.ngrams {
        for (ngram, _freq) in ngrams_map {
            let pv = visitor.prime_morphism.string_to_char_prime_vector(ngram);
            substring_prime_vectors.insert(ngram.clone(), pv);
        }
    }

    AnalysisReport {
        prime_occurrences: visitor.prime_occurrences,
        prime_factor_occurrences: visitor.prime_factor_occurrences,
        recursive_functions: visitor.recursive_functions,
        recursive_cycles: all_recursive_cycles,
        symbol_table: final_symbol_table, // Pass the populated symbol table from the visitor
        symbol_matrix,
        matrix_column_headers: all_unique_primes,
        matrix_row_headers,
        composite_prime_vectors, // Pass the populated HashMap
        char_pair_transitions: char_sequence_analyzer.pair_transitions, // NEW
        ngrams_frequencies: char_sequence_analyzer.ngrams, // NEW
        substring_prime_vectors, // NEW
    } // CLOSING BRACE FOR STRUCT LITERAL
} // CLOSING BRACE FOR run_analysis function