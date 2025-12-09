// src/analysis.rs
use num_bigint::BigUint;
use num_traits::{One, Zero};
use std::collections::HashMap;
use std::fs;
use std::path::{Path, PathBuf};
use quote::ToTokens;
use syn::{File, Item, Lit, Expr};
use syn::visit::{self, Visit};
use walkdir::WalkDir;
use crate::traits::has_embedded_primes::HasEmbeddedPrimes;
use crate::types::prime_vector::{PrimeMorphism, PrimeVector, PrimeGenerator}; // Import PrimeGenerator as well
use crate::types::keys::{
    PREDICATE_IS_FUNCTION, PREDICATE_IS_PUBLIC, PREDICATE_PARAM_COUNT,
    PREDICATE_HAS_DOC_COMMENT, PREDICATE_IS_STRUCT,
    PREDICATE_IS_ENUM, PREDICATE_IS_CONST, PREDICATE_FIELD_COUNT, PREDICATE_VARIANT_COUNT,
    PREDICATE_LITERAL_LENGTH, PREDICATE_NUMERIC_LITERAL_VALUE,
};
use crate::code_parser::{collect_code_elements_from_dir};

pub struct AnalysisReport {
    pub prime_occurrences: HashMap<u64, Vec<String>>, // Renamed from seventy_one_occurrences
    pub prime_factor_occurrences: HashMap<u64, Vec<String>>,
    pub recursive_functions: Vec<String>, // Direct recursion
    pub recursive_cycles: Vec<(String, Vec<String>)>, // (Starting function, Cycle path)
    pub symbol_table: HashMap<String, PrimeVector>, // New: Maps full path to its PrimeVector embedding
    pub symbol_matrix: Vec<Vec<u64>>, // New: Matrix representation of symbol data
    pub matrix_column_headers: Vec<u64>, // New: Ordered list of primes for matrix columns
    pub matrix_row_headers: Vec<String>, // New: Ordered list of symbol paths for matrix rows
    pub composite_prime_vectors: HashMap<String, PrimeVector>, // New: Stores aggregated prime vectors for related nodes
    pub char_pair_transitions: HashMap<(char, char), usize>, // NEW: Character pair transition frequencies
    pub ngrams_frequencies: HashMap<usize, HashMap<String, usize>>, // NEW: N-gram frequencies
    pub substring_prime_vectors: HashMap<String, PrimeVector>, // NEW: PrimeVectors for substrings
}

struct PrimeFactorizer;

impl PrimeFactorizer {
    fn get_prime_factors(n: u64) -> HashMap<u64, u32> {
        let mut factors = HashMap::new();
        let mut d = 2;
        let mut num = n;

        while d * d <= num {
            while num % d == 0 {
                *factors.entry(d).or_insert(0) += 1;
                num /= d;
            }
            d += 1;
        }
        if num > 1 {
            factors.insert(num, 1);
        }
        factors
    }
}

pub struct CharFrequencyAnalyzer {
    char_frequencies: HashMap<char, usize>,
}

impl CharFrequencyAnalyzer {
    pub fn new() -> Self {
        CharFrequencyAnalyzer {
            char_frequencies: HashMap::new(),
        }
    }

    pub fn collect_char_frequencies(&mut self, root_path: &Path) {
        let code_elements = collect_code_elements_from_dir(root_path);
        for element in code_elements {
            for ch in element.name.chars() {
                *self.char_frequencies.entry(ch).or_insert(0) += 1;
            }
            // Also consider characters in associated_idents (field/variant names)
            for ident in element.associated_idents {
                for ch in ident.chars() {
                    *self.char_frequencies.entry(ch).or_insert(0) += 1;
                }
            }
        }
    }

    pub fn generate_char_to_prime_map(self) -> HashMap<char, u64> {
        let mut sorted_chars: Vec<(char, usize)> = self.char_frequencies.into_iter().collect();
        // Sort by frequency (descending) then by char (ascending) for deterministic order
        sorted_chars.sort_by(|a, b| b.1.cmp(&a.1).then_with(|| a.0.cmp(&b.0)));

        let mut char_to_prime = HashMap::new();
        let mut prime_generator = PrimeGenerator::new(); // Each call gets a fresh generator
        
        for (ch, _freq) in sorted_chars {
            char_to_prime.insert(ch, prime_generator.get_next_prime());
        }
        char_to_prime
    }
}

pub struct CharacterSequenceAnalyzer {
    pub pair_transitions: HashMap<(char, char), usize>,
    pub ngrams: HashMap<usize, HashMap<String, usize>>,
}

impl CharacterSequenceAnalyzer {
    pub fn new() -> Self {
        let mut ngrams_map = HashMap::new();
        ngrams_map.insert(3, HashMap::new());
        ngrams_map.insert(5, HashMap::new());
        ngrams_map.insert(7, HashMap::new());
        ngrams_map.insert(11, HashMap::new());

        CharacterSequenceAnalyzer {
            pair_transitions: HashMap::new(),
            ngrams: ngrams_map,
        }
    }

    pub fn collect_from_identifiers(&mut self, identifiers: &[String]) {
        for ident in identifiers {
            self.collect_pair_transitions_from_identifier(ident);

            let mut substrings = Vec::new();
            let mut current_word = String::new();
            let mut last_char_was_upper = false;

            for c in ident.chars() {
                if c == '_' || c == '-' || c == '<' || c == '>' || c == ' ' {
                    if !current_word.is_empty() {
                        substrings.push(current_word.clone());
                        current_word.clear();
                    }
                    last_char_was_upper = false;
                } else if c.is_uppercase() {
                    if !last_char_was_upper && !current_word.is_empty() {
                        substrings.push(current_word.clone());
                        current_word.clear();
                    }
                    current_word.push(c);
                    last_char_was_upper = true;
                } else { // is_lowercase or is_numeric
                    if last_char_was_upper && current_word.len() > 1 {
                        let last_char = current_word.pop().unwrap();
                        substrings.push(current_word.clone());
                        current_word.clear();
                        current_word.push(last_char);
                    }
                    current_word.push(c);
                    last_char_was_upper = false;
                }
            }
            if !current_word.is_empty() {
                substrings.push(current_word);
            }

            for sub in substrings {
                self.collect_ngrams_from_identifier(&sub.to_lowercase(), &[3, 5, 7, 11]);
            }
        }
    }

    fn collect_pair_transitions_from_identifier(&mut self, s: &str) {
        let chars: Vec<char> = s.chars().collect();
        for i in 0..chars.len().saturating_sub(1) {
            *self.pair_transitions.entry((chars[i], chars[i+1])).or_insert(0) += 1;
        }
    }

    fn collect_ngrams_from_identifier(&mut self, s: &str, n_values: &[usize]) {
        for &n in n_values {
            if s.len() >= n {
                for i in 0..=s.len() - n {
                    let ngram = &s[i..i+n];
                    *self.ngrams.get_mut(&n).unwrap().entry(ngram.to_string()).or_insert(0) += 1;
                }
            }
        }
    }
}



struct AnalysisVisitor<'a> {
    prime_occurrences: HashMap<u64, Vec<String>>,
    prime_factor_occurrences: HashMap<u64, Vec<String>>,
    recursive_functions: Vec<String>,
    current_function: Option<String>,
    function_calls: HashMap<String, Vec<String>>,
    primes_to_analyze: &'a [u64], // Configurable list of primes
    current_path: Vec<String>, // New: Tracks the current AST path for context
    prime_morphism: PrimeMorphism, // Manages mapping string components to primes
    symbol_table: HashMap<String, PrimeVector>, // Stores PrimeVector for each full path
}

impl<'ast, 'a> visit::Visit<'ast> for AnalysisVisitor<'a> {
    fn visit_item_fn(&mut self, i: &'ast syn::ItemFn) {
        let function_name = i.sig.ident.to_string();
        self.current_function = Some(function_name.clone());
        self.current_path.push(format!("fn::{}", function_name)); // Push function name to path
        
        let full_path_str = self.current_path.join("::");
        let mut prime_vector_for_declaration = self.prime_morphism.path_to_prime_vector(&self.current_path);

        // Add predicate primes
        prime_vector_for_declaration.map.insert(self.prime_morphism.get_prime_for_component(PREDICATE_IS_FUNCTION), 1);
        if matches!(i.vis, syn::Visibility::Public(_)) {
            prime_vector_for_declaration.map.insert(self.prime_morphism.get_prime_for_component(PREDICATE_IS_PUBLIC), 1);
        }
        if !i.attrs.is_empty() { // Simple check for any attributes, including doc comments
            if i.attrs.iter().any(|attr| attr.path().is_ident("doc")) {
                prime_vector_for_declaration.map.insert(self.prime_morphism.get_prime_for_component(PREDICATE_HAS_DOC_COMMENT), 1);
            }
        }
        prime_vector_for_declaration.map.insert(self.prime_morphism.get_prime_for_component(PREDICATE_PARAM_COUNT), i.sig.inputs.len() as u64);

        // Analyze function_name as a symbol
        let s = &function_name; // Treat the function name as a string literal for analysis
        let len = s.len() as u64;
        if self.primes_to_analyze.contains(&len) {
            self.prime_occurrences.entry(len).or_default().push(format!(
                "Function name '{}' has length {}. Path: {}",
                function_name, len, full_path_str
            ));
            *prime_vector_for_declaration.map.entry(self.prime_morphism.get_prime_for_component(crate::types::keys::PREDICATE_PRIME_RESONANCE)).or_insert(0) += 1; // Mark resonance
        }
        for (prime, desc) in s.as_str().find_embedded_primes(self.primes_to_analyze) {
            if prime == 0 { // Placeholder for large primes
                self.prime_occurrences.entry(0).or_default().push(format!("Function name '{}': {}. Path: {}", function_name, desc, full_path_str));
            } else {
                self.prime_occurrences.entry(prime).or_default().push(format!("Function name '{}': {}. Path: {}", function_name, desc, full_path_str));
            }
            *prime_vector_for_declaration.map.entry(self.prime_morphism.get_prime_for_component(crate::types::keys::PREDICATE_PRIME_RESONANCE)).or_insert(0) += 1; // Mark resonance
        }
        let ascii_sum: u64 = s.bytes().map(|b| b as u64).sum();
        if ascii_sum > 1 {
            for (factor, exponent) in PrimeFactorizer::get_prime_factors(ascii_sum) {
                self.prime_factor_occurrences
                    .entry(factor)
                    .or_default()
                    .push(format!(
                        "Function name '{}' ASCII sum {} has prime factor {} with exponent {}. Path: {}",
                        function_name, ascii_sum, factor, exponent, full_path_str
                    ));
            }
        }
        
        // Store the PrimeVector for this function in the symbol table
        self.symbol_table.insert(full_path_str.clone(), prime_vector_for_declaration);

        visit::visit_item_fn(self, i);
        self.current_path.pop(); // Pop function name from path
        self.current_function = None;
    }

    fn visit_expr_call(&mut self, i: &'ast syn::ExprCall) {
        if let Some(ref current_fn) = self.current_function {
            if let Expr::Path(expr_path) = &*i.func {
                if let Some(segment) = expr_path.path.segments.last() {
                    let called_fn_name = segment.ident.to_string();
                    self.function_calls
                        .entry(current_fn.clone())
                        .or_default()
                        .push(called_fn_name);
                }
            }
        }
        visit::visit_expr_call(self, i);
    }

    fn visit_item(&mut self, item: &'ast Item) {
        match item {
            Item::Enum(item_enum) => {
                let enum_name = item_enum.ident.to_string();
                self.current_path.push(format!("enum::{}", enum_name)); // Push enum name to path
                
                let full_path_str = self.current_path.join("::");
                let mut prime_vector_for_declaration = self.prime_morphism.path_to_prime_vector(&self.current_path);

                // Add predicate primes
                prime_vector_for_declaration.map.insert(self.prime_morphism.get_prime_for_component(PREDICATE_IS_ENUM), 1);
                if matches!(item_enum.vis, syn::Visibility::Public(_)) {
                    prime_vector_for_declaration.map.insert(self.prime_morphism.get_prime_for_component(PREDICATE_IS_PUBLIC), 1);
                }
                if !item_enum.attrs.is_empty() { // Simple check for any attributes, including doc comments
                    if item_enum.attrs.iter().any(|attr| attr.path().is_ident("doc")) {
                        prime_vector_for_declaration.map.insert(self.prime_morphism.get_prime_for_component(PREDICATE_HAS_DOC_COMMENT), 1);
                    }
                }
                prime_vector_for_declaration.map.insert(self.prime_morphism.get_prime_for_component(PREDICATE_VARIANT_COUNT), item_enum.variants.len() as u64);

                // Analyze enum_name as a symbol
                let s = &enum_name; // Treat the enum name as a string literal for analysis
                let len = s.len() as u64;
                if self.primes_to_analyze.contains(&len) {
                    self.prime_occurrences.entry(len).or_default().push(format!(
                        "Enum name '{}' has length {}. Path: {}",
                        enum_name, len, full_path_str
                    ));
                    *prime_vector_for_declaration.map.entry(self.prime_morphism.get_prime_for_component(crate::types::keys::PREDICATE_PRIME_RESONANCE)).or_insert(0) += 1; // Mark resonance
                }
                for (prime, desc) in s.as_str().find_embedded_primes(self.primes_to_analyze) {
                    if prime == 0 { // Placeholder for large primes
                        self.prime_occurrences.entry(0).or_default().push(format!("Enum name '{}': {}. Path: {}", enum_name, desc, full_path_str));
                    } else {
                        self.prime_occurrences.entry(prime).or_default().push(format!("Enum name '{}': {}. Path: {}", enum_name, desc, full_path_str));
                    }
                    *prime_vector_for_declaration.map.entry(self.prime_morphism.get_prime_for_component(crate::types::keys::PREDICATE_PRIME_RESONANCE)).or_insert(0) += 1; // Mark resonance
                }
                let ascii_sum: u64 = s.bytes().map(|b| b as u64).sum();
                if ascii_sum > 1 {
                    for (factor, exponent) in PrimeFactorizer::get_prime_factors(ascii_sum) {
                        self.prime_factor_occurrences
                            .entry(factor)
                            .or_default()
                            .push(format!(
                                "Enum name '{}' ASCII sum {} has prime factor {} with exponent {}. Path: {}",
                                enum_name, ascii_sum, factor, exponent, full_path_str
                            ));
                    }
                }
                
                self.symbol_table.insert(full_path_str.clone(), prime_vector_for_declaration);

                let size = item_enum.variants.len() as u64;
                if self.primes_to_analyze.contains(&size) {
                    self.prime_occurrences.entry(size).or_default().push(format!(
                        "Enum '{}' has {} variants. Path: {}",
                        enum_name, size, full_path_str
                    ));
                }

                for variant in &item_enum.variants {
                    let variant_name = variant.ident.to_string();
                    let complexity = match &variant.fields {
                        syn::Fields::Named(fields) => fields.named.len(),
                        syn::Fields::Unnamed(fields) => fields.unnamed.len(),
                        syn::Fields::Unit => 0,
                    };

                    let report_str = format!(
                        "Enum variant '{}::{}' has complexity (number of fields): {}. Path: {}",
                        enum_name, variant_name, complexity, full_path_str
                    );
                    self.prime_occurrences.entry(0).or_default().push(report_str);
                }
                
                visit::visit_item_enum(self, item_enum); // Visit variants
                self.current_path.pop(); // Pop enum name from path
            }            Item::Struct(item_struct) => {
                let struct_name = item_struct.ident.to_string();
                self.current_path.push(format!("struct::{}", struct_name)); // Push struct name to path

                let full_path_str = self.current_path.join("::");
                let mut prime_vector_for_declaration = self.prime_morphism.path_to_prime_vector(&self.current_path);

                // Add predicate primes
                prime_vector_for_declaration.map.insert(self.prime_morphism.get_prime_for_component(PREDICATE_IS_STRUCT), 1);
                if matches!(item_struct.vis, syn::Visibility::Public(_)) {
                    prime_vector_for_declaration.map.insert(self.prime_morphism.get_prime_for_component(PREDICATE_IS_PUBLIC), 1);
                }
                if !item_struct.attrs.is_empty() { // Simple check for any attributes, including doc comments
                    if item_struct.attrs.iter().any(|attr| attr.path().is_ident("doc")) {
                        prime_vector_for_declaration.map.insert(self.prime_morphism.get_prime_for_component(PREDICATE_HAS_DOC_COMMENT), 1);
                    }
                }
                prime_vector_for_declaration.map.insert(self.prime_morphism.get_prime_for_component(PREDICATE_FIELD_COUNT), item_struct.fields.len() as u64);
                
                // Analyze struct_name as a symbol
                let s = &struct_name; // Treat the struct name as a string literal for analysis
                let len = s.len() as u64;
                if self.primes_to_analyze.contains(&len) {
                    self.prime_occurrences.entry(len).or_default().push(format!(
                        "Struct name '{}' has length {}. Path: {}",
                        struct_name, len, full_path_str
                    ));
                    *prime_vector_for_declaration.map.entry(self.prime_morphism.get_prime_for_component(crate::types::keys::PREDICATE_PRIME_RESONANCE)).or_insert(0) += 1; // Mark resonance
                }
                for (prime, desc) in s.as_str().find_embedded_primes(self.primes_to_analyze) {
                    if prime == 0 { // Placeholder for large primes
                        self.prime_occurrences.entry(0).or_default().push(format!("Struct name '{}': {}. Path: {}", struct_name, desc, full_path_str));
                    } else {
                        self.prime_occurrences.entry(prime).or_default().push(format!("Struct name '{}': {}. Path: {}", struct_name, desc, full_path_str));
                    }
                    *prime_vector_for_declaration.map.entry(self.prime_morphism.get_prime_for_component(crate::types::keys::PREDICATE_PRIME_RESONANCE)).or_insert(0) += 1; // Mark resonance
                }
                let ascii_sum: u64 = s.bytes().map(|b| b as u64).sum();
                if ascii_sum > 1 {
                    for (factor, exponent) in PrimeFactorizer::get_prime_factors(ascii_sum) {
                        self.prime_factor_occurrences
                            .entry(factor)
                            .or_default()
                            .push(format!(
                                "Struct name '{}' ASCII sum {} has prime factor {} with exponent {}. Path: {}",
                                struct_name, ascii_sum, factor, exponent, full_path_str
                            ));
                    }
                }
                
                self.symbol_table.insert(full_path_str.clone(), prime_vector_for_declaration);

                let size = item_struct.fields.len() as u64;
                if size > 1 {
                    let factors = PrimeFactorizer::get_prime_factors(size);
                    let is_prime = factors.len() == 1 && factors.get(&size).map_or(false, |&exp| exp == 1);

                    if !is_prime {
                        let factors_str = factors.iter().map(|(f, e)| format!("{}^{}", f, e)).collect::<Vec<String>>().join(" * ");
                        self.prime_occurrences.entry(0).or_default().push(format!(
                            "Struct '{}' has {} fields. Factorization: {}. Path: {}",
                            struct_name, size, factors_str, full_path_str
                        ));
                    } else {
                        if self.primes_to_analyze.contains(&size) {
                            self.prime_occurrences.entry(size).or_default().push(format!(
                                "Struct '{}' has a prime number of {} fields. Path: {}",
                                struct_name, size, full_path_str
                            ));
                        }
                    }
                } else {
                     if self.primes_to_analyze.contains(&size) {
                        self.prime_occurrences.entry(size).or_default().push(format!(
                            "Struct '{}' has {} fields. Path: {}",
                            struct_name, size, full_path_str
                        ));
                    }
                }
                visit::visit_item_struct(self, item_struct); // Visit fields
                self.current_path.pop(); // Pop struct name from path
            }
            Item::Mod(item_mod) => {
                let mod_name = item_mod.ident.to_string();
                self.current_path.push(format!("mod::{}", mod_name)); // Push module name to path
                
                let full_path_str = self.current_path.join("::");
                let mut prime_vector_for_declaration = self.prime_morphism.path_to_prime_vector(&self.current_path);

                // Add predicate primes
                // Modules don't have explicit visibility or doc comments in the same way functions/structs do
                // We'll add a predicate for being a module.
                // You might extend this to count public items, etc.
                prime_vector_for_declaration.map.insert(self.prime_morphism.get_prime_for_component("predicate::is_module"), 1);

                // Analyze mod_name as a symbol
                let s = &mod_name; // Treat the module name as a string literal for analysis
                let len = s.len() as u64;
                if self.primes_to_analyze.contains(&len) {
                    self.prime_occurrences.entry(len).or_default().push(format!(
                        "Module name '{}' has length {}. Path: {}",
                        mod_name, len, full_path_str
                    ));
                    *prime_vector_for_declaration.map.entry(self.prime_morphism.get_prime_for_component(crate::types::keys::PREDICATE_PRIME_RESONANCE)).or_insert(0) += 1; // Mark resonance
                }
                for (prime, desc) in s.as_str().find_embedded_primes(self.primes_to_analyze) {
                    if prime == 0 { // Placeholder for large primes
                        self.prime_occurrences.entry(0).or_default().push(format!("Module name '{}': {}. Path: {}", mod_name, desc, full_path_str));
                    } else {
                        self.prime_occurrences.entry(prime).or_default().push(format!("Module name '{}': {}. Path: {}", mod_name, desc, full_path_str));
                    }
                    *prime_vector_for_declaration.map.entry(self.prime_morphism.get_prime_for_component(crate::types::keys::PREDICATE_PRIME_RESONANCE)).or_insert(0) += 1; // Mark resonance
                }
                let ascii_sum: u64 = s.bytes().map(|b| b as u64).sum();
                if ascii_sum > 1 {
                    for (factor, exponent) in PrimeFactorizer::get_prime_factors(ascii_sum) {
                        self.prime_factor_occurrences
                            .entry(factor)
                            .or_default()
                            .push(format!(
                                "Module name '{}' ASCII sum {} has prime factor {} with exponent {}. Path: {}",
                                mod_name, ascii_sum, factor, exponent, full_path_str
                            ));
                    }
                }

                self.symbol_table.insert(full_path_str.clone(), prime_vector_for_declaration);

                if let Some((_, items)) = &item_mod.content {
                    let public_fns = items
                        .iter()
                        .filter(|item| match item {
                            Item::Fn(item_fn) => {
                                matches!(item_fn.vis, syn::Visibility::Public(_))
                            }
                            _ => false,
                        })
                        .count() as u64;
                    if self.primes_to_analyze.contains(&public_fns) {
                        self.prime_occurrences.entry(public_fns).or_default().push(format!(
                            "Module '{}' has {} public functions. Path: {}",
                            mod_name, public_fns, full_path_str
                        ));
                    }
                }
                visit::visit_item_mod(self, item_mod); // Visit module contents
                self.current_path.pop(); // Pop module name from path
            }            Item::Fn(item_fn) => {
                let fn_name = item_fn.sig.ident.to_string();
                // This branch is for Item::Fn that are not top-level (e.g. associated functions,
                // or functions inside blocks/modules, where visit_item_fn might not catch all).
                // Ensure to push/pop path and generate PrimeVector here.
                self.current_path.push(format!("fn::{}", fn_name));
                let full_path_str = self.current_path.join("::");
                let mut prime_vector_for_declaration = self.prime_morphism.path_to_prime_vector(&self.current_path);

                // Add predicate primes
                prime_vector_for_declaration.map.insert(self.prime_morphism.get_prime_for_component(PREDICATE_IS_FUNCTION), 1);
                if matches!(item_fn.vis, syn::Visibility::Public(_)) {
                    prime_vector_for_declaration.map.insert(self.prime_morphism.get_prime_for_component(PREDICATE_IS_PUBLIC), 1);
                }
                if !item_fn.attrs.is_empty() { // Simple check for any attributes, including doc comments
                    if item_fn.attrs.iter().any(|attr| attr.path().is_ident("doc")) {
                        prime_vector_for_declaration.map.insert(self.prime_morphism.get_prime_for_component(PREDICATE_HAS_DOC_COMMENT), 1);
                    }
                }
                prime_vector_for_declaration.map.insert(self.prime_morphism.get_prime_for_component(PREDICATE_PARAM_COUNT), item_fn.sig.inputs.len() as u64);

                // Analyze fn_name as a symbol
                let s = &fn_name; // Treat the function name as a string literal for analysis
                let len = s.len() as u64;
                if self.primes_to_analyze.contains(&len) {
                    self.prime_occurrences.entry(len).or_default().push(format!(
                        "Function name (nested) '{}' has length {}. Path: {}",
                        fn_name, len, full_path_str
                    ));
                    *prime_vector_for_declaration.map.entry(self.prime_morphism.get_prime_for_component(crate::types::keys::PREDICATE_PRIME_RESONANCE)).or_insert(0) += 1; // Mark resonance
                }
                for (prime, desc) in s.as_str().find_embedded_primes(self.primes_to_analyze) {
                    if prime == 0 { // Placeholder for large primes
                        self.prime_occurrences.entry(0).or_default().push(format!("Function name (nested) '{}': {}. Path: {}", fn_name, desc, full_path_str));
                    } else {
                        self.prime_occurrences.entry(prime).or_default().push(format!("Function name (nested) '{}': {}. Path: {}", fn_name, desc, full_path_str));
                    }
                    *prime_vector_for_declaration.map.entry(self.prime_morphism.get_prime_for_component(crate::types::keys::PREDICATE_PRIME_RESONANCE)).or_insert(0) += 1; // Mark resonance
                }
                let ascii_sum: u64 = s.bytes().map(|b| b as u64).sum();
                if ascii_sum > 1 {
                    for (factor, exponent) in PrimeFactorizer::get_prime_factors(ascii_sum) {
                        self.prime_factor_occurrences
                            .entry(factor)
                            .or_default()
                            .push(format!(
                                "Function name (nested) '{}' ASCII sum {} has prime factor {} with exponent {}. Path: {}",
                                fn_name, ascii_sum, factor, exponent, full_path_str
                            ));
                    }
                }

                self.symbol_table.insert(full_path_str.clone(), prime_vector_for_declaration);

                let param_count = item_fn.sig.inputs.len() as u64;
                if self.primes_to_analyze.contains(&param_count) {
                    self.prime_occurrences.entry(param_count).or_default().push(format!(
                        "Function '{}' has {} parameters. Path: {}",
                        fn_name, param_count, full_path_str
                    ));
                }
                visit::visit_item_fn(self, item_fn); // Continue visiting children of the function
                self.current_path.pop(); // Pop function name from path
            }            Item::Const(item_const) => {
                let const_name = item_const.ident.to_string();
                self.current_path.push(format!("const::{}", const_name)); // Push const name to path

                let full_path_str = self.current_path.join("::");
                let mut prime_vector_for_declaration = self.prime_morphism.path_to_prime_vector(&self.current_path);

                // Add predicate primes
                prime_vector_for_declaration.map.insert(self.prime_morphism.get_prime_for_component(PREDICATE_IS_CONST), 1);
                if matches!(item_const.vis, syn::Visibility::Public(_)) {
                    prime_vector_for_declaration.map.insert(self.prime_morphism.get_prime_for_component(PREDICATE_IS_PUBLIC), 1);
                }
                if !item_const.attrs.is_empty() { // Simple check for any attributes, including doc comments
                    if item_const.attrs.iter().any(|attr| attr.path().is_ident("doc")) {
                        prime_vector_for_declaration.map.insert(self.prime_morphism.get_prime_for_component(PREDICATE_HAS_DOC_COMMENT), 1);
                    }
                }

                // Analyze const_name as a symbol
                let s = &const_name; // Treat the constant name as a string literal for analysis
                let len = s.len() as u64;
                if self.primes_to_analyze.contains(&len) {
                    self.prime_occurrences.entry(len).or_default().push(format!(
                        "Constant name '{}' has length {}. Path: {}",
                        const_name, len, full_path_str
                    ));
                    *prime_vector_for_declaration.map.entry(self.prime_morphism.get_prime_for_component(crate::types::keys::PREDICATE_PRIME_RESONANCE)).or_insert(0) += 1; // Mark resonance
                }
                for (prime, desc) in s.as_str().find_embedded_primes(self.primes_to_analyze) {
                    if prime == 0 { // Placeholder for large primes
                        self.prime_occurrences.entry(0).or_default().push(format!("Constant name '{}': {}. Path: {}", const_name, desc, full_path_str));
                    } else {
                        self.prime_occurrences.entry(prime).or_default().push(format!("Constant name '{}': {}. Path: {}", const_name, desc, full_path_str));
                    }
                    *prime_vector_for_declaration.map.entry(self.prime_morphism.get_prime_for_component(crate::types::keys::PREDICATE_PRIME_RESONANCE)).or_insert(0) += 1; // Mark resonance
                }
                let ascii_sum: u64 = s.bytes().map(|b| b as u64).sum();
                if ascii_sum > 1 {
                    for (factor, exponent) in PrimeFactorizer::get_prime_factors(ascii_sum) {
                        self.prime_factor_occurrences
                            .entry(factor)
                            .or_default()
                            .push(format!(
                                "Constant name '{}' ASCII sum {} has prime factor {} with exponent {}. Path: {}",
                                const_name, ascii_sum, factor, exponent, full_path_str
                            ));
                    }
                }

                if let syn::Expr::Lit(expr_lit) = &*item_const.expr {
                    if let Lit::Str(lit_str) = &expr_lit.lit {
                        let s = lit_str.value();
                        let len = s.len() as u64;
                        prime_vector_for_declaration.map.insert(self.prime_morphism.get_prime_for_component(PREDICATE_LITERAL_LENGTH), len);

                        // Check for string literal length resonance
                        if self.primes_to_analyze.contains(&len) {
                            self.prime_occurrences.entry(len).or_default().push(format!(
                                "String literal in const '{}' has length {}. Path: {}",
                                const_name, len, full_path_str
                            ));
                            *prime_vector_for_declaration.map.entry(self.prime_morphism.get_prime_for_component(crate::types::keys::PREDICATE_PRIME_RESONANCE)).or_insert(0) += 1; // Mark resonance
                        }

                        // Check for embedded primes in the string literal
                        for (prime, desc) in s.as_str().find_embedded_primes(self.primes_to_analyze) {
                            if prime == 0 { // Placeholder for large primes
                                self.prime_occurrences.entry(0).or_default().push(format!("Const '{}': {}. Path: {}", const_name, desc, full_path_str));
                            } else {
                                self.prime_occurrences.entry(prime).or_default().push(format!("Const '{}': {}. Path: {}", const_name, desc, full_path_str));
                            }
                            *prime_vector_for_declaration.map.entry(self.prime_morphism.get_prime_for_component(crate::types::keys::PREDICATE_PRIME_RESONANCE)).or_insert(0) += 1; // Mark resonance
                        }

                        // Prime factorization of ASCII sum
                        let ascii_sum: u64 = s.bytes().map(|b| b as u64).sum();
                        if ascii_sum > 1 {
                            for (factor, exponent) in PrimeFactorizer::get_prime_factors(ascii_sum) {
                                self.prime_factor_occurrences
                                    .entry(factor)
                                    .or_default()
                                    .push(format!(
                                        "String literal \"{}\" in const '{}' (ASCII sum {}) has prime factor {} with exponent {}. Path: {}",
                                        s, const_name, ascii_sum, factor, exponent, full_path_str
                                    ));
                            }
                        }
                    } else if let Lit::Int(lit_int) = &expr_lit.lit {
                        if let Ok(num) = lit_int.base10_parse::<u64>() {
                            prime_vector_for_declaration.map.insert(self.prime_morphism.get_prime_for_component(PREDICATE_NUMERIC_LITERAL_VALUE), num);

                            if self.primes_to_analyze.contains(&num) {
                                self.prime_occurrences.entry(num).or_default().push(format!(
                                    "Found numeric literal {} in const '{}'. Path: {}",
                                    num, const_name, full_path_str
                                ));
                                *prime_vector_for_declaration.map.entry(self.prime_morphism.get_prime_for_component(crate::types::keys::PREDICATE_PRIME_RESONANCE)).or_insert(0) += 1; // Mark resonance
                            }
                            if num > 1 {
                                for (factor, exponent) in PrimeFactorizer::get_prime_factors(num) {
                                    self.prime_factor_occurrences
                                        .entry(factor)
                                        .or_default()
                                        .push(format!(
                                            "Const '{}' with value {} has prime factor {} with exponent {}. Path: {}",
                                            const_name, num, factor, exponent, full_path_str
                                        ));
                                }
                            }
                        }
                    }
                }
                self.symbol_table.insert(full_path_str.clone(), prime_vector_for_declaration); // Store the final PrimeVector for this constant
                self.current_path.pop(); // Pop const name from path
            }            _ => {}
        }
        visit::visit_item(self, item);
    }
    
    // Also visit expressions for standalone literals outside of consts
    fn visit_expr(&mut self, expr: &'ast Expr) {
        if let Expr::Lit(expr_lit) = expr {
            if let Lit::Int(lit_int) = &expr_lit.lit {
                if let Ok(num) = lit_int.base10_parse::<u64>() {
                    if self.primes_to_analyze.contains(&num) {
                        self.prime_occurrences.entry(num).or_default().push(format!("Found numeric literal {}. Path: {}", num, self.current_path.join("::")));
                    }
                    if num > 1 {
                                            for (factor, exponent) in PrimeFactorizer::get_prime_factors(num) {
                                                self.prime_factor_occurrences
                                                    .entry(factor)
                                                    .or_default()
                                                    .push(format!("Numeric literal {} has prime factor {} with exponent {}. Path: {}", num, factor, exponent, self.current_path.join("::")));
                                            }                    }
                }
            } else if let Lit::Str(lit_str) = &expr_lit.lit {
                let s = lit_str.value();

                // Check for string literal length resonance
                let len = s.len() as u64;
                if self.primes_to_analyze.contains(&len) {
                    self.prime_occurrences.entry(len).or_default().push(format!("Found string literal with length {}. Path: {}", len, self.current_path.join("::")));
                }

                // Check for embedded primes in the string literal
                for (prime, desc) in s.as_str().find_embedded_primes(self.primes_to_analyze) {
                    if prime == 0 { // Placeholder for large primes
                        self.prime_occurrences.entry(0).or_default().push(format!("{}. Path: {}", desc, self.current_path.join("::")));
                    } else {
                        self.prime_occurrences.entry(prime).or_default().push(format!("{}. Path: {}", desc, self.current_path.join("::")));
                    }
                }

                let ascii_sum: u64 = s.bytes().map(|b| b as u64).sum();
                if ascii_sum > 1 {
                    for (factor, exponent) in PrimeFactorizer::get_prime_factors(ascii_sum) {
                        self.prime_factor_occurrences
                            .entry(factor)
                            .or_default()
                            .push(format!("String literal \"{}\" ASCII sum {} has prime factor {} with exponent {}. Path: {}", s, ascii_sum, factor, exponent, self.current_path.join("::")));
                    }
                }
            }
        }
        visit::visit_expr(self, expr);
    }

    fn visit_local(&mut self, i: &'ast syn::Local) {
        if let syn::Pat::Type(pat_type) = &i.pat {
            if let syn::Pat::Ident(pat_ident) = &*pat_type.pat {
                let var_name = pat_ident.ident.to_string();
                self.current_path.push(format!("let::{}", var_name));
                let full_path_str = self.current_path.join("::");

                let mut prime_vector = self.prime_morphism.path_to_prime_vector(&self.current_path);

                let type_name = pat_type.ty.to_token_stream().to_string();
                prime_vector.map.insert(self.prime_morphism.get_prime_for_component(&format!("type::{}", type_name)), 1);

                if pat_ident.mutability.is_some() {
                    prime_vector.map.insert(self.prime_morphism.get_prime_for_component("usage::mut"), 1);
                }

                self.symbol_table.insert(full_path_str, prime_vector);
                self.current_path.pop();
            }
        } else if let syn::Pat::Ident(pat_ident) = &i.pat {
            let var_name = pat_ident.ident.to_string();
            self.current_path.push(format!("let::{}", var_name));
            let full_path_str = self.current_path.join("::");

            let mut prime_vector = self.prime_morphism.path_to_prime_vector(&self.current_path);

            if pat_ident.mutability.is_some() {
                prime_vector.map.insert(self.prime_morphism.get_prime_for_component("usage::mut"), 1);
            }

            self.symbol_table.insert(full_path_str, prime_vector);
            self.current_path.pop();
        }

        visit::visit_local(self, i);
    }

    fn visit_fn_arg(&mut self, i: &'ast syn::FnArg) {
        if let syn::FnArg::Typed(pat_type) = i {
            if let syn::Pat::Ident(pat_ident) = &*pat_type.pat {
                let arg_name = pat_ident.ident.to_string();
                self.current_path.push(format!("arg::{}", arg_name));
                let full_path_str = self.current_path.join("::");

                let mut prime_vector = self.prime_morphism.path_to_prime_vector(&self.current_path);

                let type_name = pat_type.ty.to_token_stream().to_string();
                prime_vector.map.insert(self.prime_morphism.get_prime_for_component(&format!("type::{}", type_name)), 1);

                if pat_ident.mutability.is_some() {
                    prime_vector.map.insert(self.prime_morphism.get_prime_for_component("usage::mut"), 1);
                }

                if arg_name == "self" {
                    prime_vector.map.insert(self.prime_morphism.get_prime_for_component("usage::self"), 1);
                }

                self.symbol_table.insert(full_path_str, prime_vector);
                self.current_path.pop();
            }
        }
        visit::visit_fn_arg(self, i);
    }
}

// Helper function for DFS-based cycle detection
fn find_cycles_dfs(
    graph: &HashMap<String, Vec<String>>,
    node: &str,
    visited: &mut HashMap<String, bool>,
    recursion_stack: &mut HashMap<String, bool>,
    path: &mut Vec<String>,
    cycles: &mut Vec<(String, Vec<String>)>,
    primes_to_check: &[u64],
) {
    visited.insert(node.to_string(), true);
    recursion_stack.insert(node.to_string(), true);
    path.push(node.to_string());

    if let Some(callees) = graph.get(node) {
        for callee in callees {
            if !visited.get(callee).unwrap_or(&false) {
                find_cycles_dfs(graph, callee, visited, recursion_stack, path, cycles, primes_to_check);
            } else if *recursion_stack.get(callee).unwrap_or(&false) {
                // Cycle detected!
                let cycle_start_index = path.iter().position(|f| f == callee).unwrap();
                let cycle_path: Vec<String> = path[cycle_start_index..].to_vec();
                
                // Check if cycle length matches any of the configured primes
                if primes_to_check.contains(&(cycle_path.len() as u64)) {
                    cycles.push((node.to_string(), cycle_path));
                }
            }
        }
    }

    path.pop();
    recursion_stack.insert(node.to_string(), false);
}


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
        crate_root_vector.map.insert(visitor.prime_morphism.get_prime_for_component(crate::types::keys::PREDICATE_IS_CRATE), 1);
    }
    // Check if it's an executable crate (main.rs exists)
    if path.join("src").join("main.rs").exists() {
        crate_root_vector.map.insert(visitor.prime_morphism.get_prime_for_component(crate::types::keys::PREDICATE_IS_EXE), 1);
    }
    // Check for Nix flake (flake.nix exists)
    if path.join("flake.nix").exists() {
        crate_root_vector.map.insert(visitor.prime_morphism.get_prime_for_component(crate::types::keys::PREDICATE_IS_NIX_FLAKE), 1);
    }
    // Check for Git repository (.git directory exists)
    if path.join(".git").exists() {
        crate_root_vector.map.insert(visitor.prime_morphism.get_prime_for_component(crate::types::keys::PREDICATE_IS_GIT_REPOSITORY), 1);
        // Check if on an active Git branch (not detached HEAD)
        // For now, a simpler heuristic: if .git/HEAD contains "ref: refs/heads/", it's probably on a branch.
        if let Ok(head_content) = std::fs::read_to_string(path.join(".git").join("HEAD")) {
            if head_content.starts_with("ref: refs/heads/") {
                crate_root_vector.map.insert(visitor.prime_morphism.get_prime_for_component(crate::types::keys::PREDICATE_IS_GIT_BRANCH_ACTIVE), 1);
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