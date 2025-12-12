use std::collections::HashMap;
// use std::fs; // Removed unused import
// use std::path::{Path, PathBuf}; // Removed unused import
use quote::ToTokens;
use syn::{Item, Lit, Expr}; // Keep File for visit_file in analyzer.rs, though it's here to ensure compilation
use syn::visit::{self}; // Ensure Visit is in scope for the trait implementation
// use walkdir::WalkDir; // Removed unused import
use svg_hir::traits::has_embedded_primes::HasEmbeddedPrimes;
use svg_hir::prime_vector::{PrimeMorphism, PrimeVector}; // Removed unused PrimeGenerator
use svg_hir::keys::{
    PREDICATE_IS_FUNCTION, PREDICATE_IS_PUBLIC, PREDICATE_PARAM_COUNT,
    PREDICATE_HAS_DOC_COMMENT, PREDICATE_IS_STRUCT,
    PREDICATE_IS_ENUM, PREDICATE_IS_CONST, PREDICATE_FIELD_COUNT, PREDICATE_VARIANT_COUNT,
    PREDICATE_LITERAL_LENGTH, PREDICATE_NUMERIC_LITERAL_VALUE,
};
use crate::prime_factorization::PrimeFactorizer; // Import PrimeFactorizer

pub struct AnalysisVisitor<'a> {
    pub prime_occurrences: HashMap<u64, Vec<String>>,
    pub prime_factor_occurrences: HashMap<u64, Vec<String>>,
    pub recursive_functions: Vec<String>,
    pub current_function: Option<String>,
    pub function_calls: HashMap<String, Vec<String>>,
    pub primes_to_analyze: &'a [u64], // Configurable list of primes
    pub current_path: Vec<String>, // New: Tracks the current AST path for context
    pub prime_morphism: PrimeMorphism, // Manages mapping string components to primes
    pub symbol_table: HashMap<String, PrimeVector>, // Stores PrimeVector for each full path
    pub crate_name: String, // NEW: Store the current crate name
}

impl<'ast, 'a> visit::Visit<'ast> for AnalysisVisitor<'a> {
    fn visit_item_fn(&mut self, i: &'ast syn::ItemFn) {
        eprintln!("DEBUG: AnalysisVisitor::visit_item_fn for: {}", i.sig.ident);
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
            *prime_vector_for_declaration.map.entry(self.prime_morphism.get_prime_for_component(svg_hir::keys::PREDICATE_PRIME_RESONANCE)).or_insert(0) += 1; // Mark resonance
        }
        for (prime, desc) in s.as_str().find_embedded_primes(self.primes_to_analyze) {
            if prime == 0 { // Placeholder for large primes
                self.prime_occurrences.entry(0).or_default().push(format!("Function name '{}': {}. Path: {}", function_name, desc, full_path_str));
            } else {
                self.prime_occurrences.entry(prime).or_default().push(format!("Function name '{}': {}. Path: {}", function_name, desc, full_path_str));
            }
            *prime_vector_for_declaration.map.entry(self.prime_morphism.get_prime_for_component(svg_hir::keys::PREDICATE_PRIME_RESONANCE)).or_insert(0) += 1; // Mark resonance
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
        eprintln!("DEBUG: Exiting AnalysisVisitor::visit_item_fn for: {}", function_name);
    }

    fn visit_expr_call(&mut self, i: &'ast syn::ExprCall) {
        // eprintln!("DEBUG: AnalysisVisitor::visit_expr_call");
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
        eprintln!("DEBUG: AnalysisVisitor::visit_item. Current path: {}", self.current_path.join("::"));
        match item {
            Item::Enum(item_enum) => {
                eprintln!("DEBUG: Found enum: {}", item_enum.ident);
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
                    *prime_vector_for_declaration.map.entry(self.prime_morphism.get_prime_for_component(svg_hir::keys::PREDICATE_PRIME_RESONANCE)).or_insert(0) += 1; // Mark resonance
                }
                for (prime, desc) in s.as_str().find_embedded_primes(self.primes_to_analyze) {
                    if prime == 0 { // Placeholder for large primes
                        self.prime_occurrences.entry(0).or_default().push(format!("Enum name '{}': {}. Path: {}", enum_name, desc, full_path_str));
                    } else {
                        self.prime_occurrences.entry(prime).or_default().push(format!("Enum name '{}': {}. Path: {}", enum_name, desc, full_path_str));
                    }
                    *prime_vector_for_declaration.map.entry(self.prime_morphism.get_prime_for_component(svg_hir::keys::PREDICATE_PRIME_RESONANCE)).or_insert(0) += 1; // Mark resonance
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
            }
            Item::Struct(item_struct) => {
                eprintln!("DEBUG: Found struct: {}", item_struct.ident);
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
                    *prime_vector_for_declaration.map.entry(self.prime_morphism.get_prime_for_component(svg_hir::keys::PREDICATE_PRIME_RESONANCE)).or_insert(0) += 1; // Mark resonance
                }
                for (prime, desc) in s.as_str().find_embedded_primes(self.primes_to_analyze) {
                    if prime == 0 { // Placeholder for large primes
                        self.prime_occurrences.entry(0).or_default().push(format!("Struct name '{}': {}. Path: {}", struct_name, desc, full_path_str));
                    } else {
                        self.prime_occurrences.entry(prime).or_default().push(format!("Struct name '{}': {}. Path: {}", struct_name, desc, full_path_str));
                    }
                    *prime_vector_for_declaration.map.entry(self.prime_morphism.get_prime_for_component(svg_hir::keys::PREDICATE_PRIME_RESONANCE)).or_insert(0) += 1; // Mark resonance
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
                        let factors_str = factors.iter().map(|(f, e)| format!("{}=>{}", f, e)).collect::<Vec<String>>().join(" * ");
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
                eprintln!("DEBUG: Found mod: {}", item_mod.ident);
                let mod_name = item_mod.ident.to_string();
                self.current_path.push(format!("mod::{}", mod_name)); // Push module name to path

                let full_path_str = self.current_path.join("::");
                let mut prime_vector_for_declaration = self.prime_morphism.path_to_prime_vector(&self.current_path);

                // Add predicate primes
                prime_vector_for_declaration.map.insert(self.prime_morphism.get_prime_for_component("predicate::is_module"), 1);

                // Analyze mod_name as a symbol
                let s = &mod_name; // Treat the module name as a string literal for analysis
                let len = s.len() as u64;
                if self.primes_to_analyze.contains(&len) {
                    self.prime_occurrences.entry(len).or_default().push(format!(
                        "Module name '{}' has length {}. Path: {}",
                        mod_name, len, full_path_str
                    ));
                    *prime_vector_for_declaration.map.entry(self.prime_morphism.get_prime_for_component(svg_hir::keys::PREDICATE_PRIME_RESONANCE)).or_insert(0) += 1; // Mark resonance
                }
                for (prime, desc) in s.as_str().find_embedded_primes(self.primes_to_analyze) {
                    if prime == 0 { // Placeholder for large primes
                        self.prime_occurrences.entry(0).or_default().push(format!("Module name '{}': {}. Path: {}", mod_name, desc, full_path_str));
                    } else {
                        self.prime_occurrences.entry(prime).or_default().push(format!("Module name '{}': {}. Path: {}", mod_name, desc, full_path_str));
                    }
                    *prime_vector_for_declaration.map.entry(self.prime_morphism.get_prime_for_component(svg_hir::keys::PREDICATE_PRIME_RESONANCE)).or_insert(0) += 1; // Mark resonance
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
            }
            Item::Fn(item_fn) => {
                eprintln!("DEBUG: Found inner fn: {}", item_fn.sig.ident);
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
                    *prime_vector_for_declaration.map.entry(self.prime_morphism.get_prime_for_component(svg_hir::keys::PREDICATE_PRIME_RESONANCE)).or_insert(0) += 1; // Mark resonance
                }
                for (prime, desc) in s.as_str().find_embedded_primes(self.primes_to_analyze) {
                    if prime == 0 { // Placeholder for large primes
                        self.prime_occurrences.entry(0).or_default().push(format!("Function name (nested) '{}': {}. Path: {}", fn_name, desc, full_path_str));
                    } else {
                        self.prime_occurrences.entry(prime).or_default().push(format!("Function name (nested) '{}': {}. Path: {}", fn_name, desc, full_path_str));
                    }
                    *prime_vector_for_declaration.map.entry(self.prime_morphism.get_prime_for_component(svg_hir::keys::PREDICATE_PRIME_RESONANCE)).or_insert(0) += 1; // Mark resonance
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
            }
            Item::Const(item_const) => {
                eprintln!("DEBUG: Found const: {}", item_const.ident);
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
                    *prime_vector_for_declaration.map.entry(self.prime_morphism.get_prime_for_component(svg_hir::keys::PREDICATE_PRIME_RESONANCE)).or_insert(0) += 1; // Mark resonance
                }
                for (prime, desc) in s.as_str().find_embedded_primes(self.primes_to_analyze) {
                    if prime == 0 { // Placeholder for large primes
                        self.prime_occurrences.entry(0).or_default().push(format!("Const '{}': {}. Path: {}", const_name, desc, full_path_str));
                    } else {
                        self.prime_occurrences.entry(prime).or_default().push(format!("Const '{}': {}. Path: {}", const_name, desc, full_path_str));
                    }
                    *prime_vector_for_declaration.map.entry(self.prime_morphism.get_prime_for_component(svg_hir::keys::PREDICATE_PRIME_RESONANCE)).or_insert(0) += 1; // Mark resonance
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
                        eprintln!("DEBUG: Found string literal in const '{}': {}", const_name, lit_str.value());
                        let s = lit_str.value();
                        let len = s.len() as u64;
                        prime_vector_for_declaration.map.insert(self.prime_morphism.get_prime_for_component(PREDICATE_LITERAL_LENGTH), len);

                        // Check for string literal length resonance
                        if self.primes_to_analyze.contains(&len) {
                            self.prime_occurrences.entry(len).or_default().push(format!(
                                "String literal in const '{}' has length {}. Path: {}",
                                const_name, len, full_path_str
                            ));
                            *prime_vector_for_declaration.map.entry(self.prime_morphism.get_prime_for_component(svg_hir::keys::PREDICATE_PRIME_RESONANCE)).or_insert(0) += 1; // Mark resonance
                        }

                        // Check for embedded primes in the string literal
                        for (prime, desc) in s.as_str().find_embedded_primes(self.primes_to_analyze) {
                            if prime == 0 { // Placeholder for large primes
                                self.prime_occurrences.entry(0).or_default().push(format!("Const '{}': {}. Path: {}", const_name, desc, full_path_str));
                            } else {
                                self.prime_occurrences.entry(prime).or_default().push(format!("Const '{}': {}. Path: {}", const_name, desc, full_path_str));
                            }
                            *prime_vector_for_declaration.map.entry(self.prime_morphism.get_prime_for_component(svg_hir::keys::PREDICATE_PRIME_RESONANCE)).or_insert(0) += 1; // Mark resonance
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
                        eprintln!("DEBUG: Found int literal in const '{}': {}", const_name, lit_int);
                        if let Ok(num) = lit_int.base10_parse::<u64>() {
                            prime_vector_for_declaration.map.insert(self.prime_morphism.get_prime_for_component(PREDICATE_NUMERIC_LITERAL_VALUE), num);

                            if self.primes_to_analyze.contains(&num) {
                                self.prime_occurrences.entry(num).or_default().push(format!(
                                    "Found numeric literal {} in const '{}'. Path: {}",
                                    num, const_name, full_path_str
                                ));
                                *prime_vector_for_declaration.map.entry(self.prime_morphism.get_prime_for_component(svg_hir::keys::PREDICATE_PRIME_RESONANCE)).or_insert(0) += 1; // Mark resonance
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
            }
            _ => {} // Ignore other item types for now
        }
        eprintln!("DEBUG: Exiting AnalysisVisitor::visit_item");
        visit::visit_item(self, item);
    }
    
    // Also visit expressions for standalone literals outside of consts
    fn visit_expr(&mut self, expr: &'ast Expr) {
        // eprintln!("DEBUG: AnalysisVisitor::visit_expr");
        if let Expr::Lit(expr_lit) = expr {
            if let Lit::Int(lit_int) = &expr_lit.lit {
                // eprintln!("DEBUG: Found int literal in expr: {}", lit_int);
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
                                            }
                                        }
                }
            } else if let Lit::Str(lit_str) = &expr_lit.lit {
                // eprintln!("DEBUG: Found string literal in expr: {}", lit_str.value());
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
                    // Removed incorrect reference to prime_vector_for_declaration
                    // *prime_vector_for_declaration.map.entry(self.prime_morphism.get_prime_for_component(svg_hir::keys::PREDICATE_PRIME_RESONANCE)).or_insert(0) += 1; // Mark resonance
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
        // eprintln!("DEBUG: AnalysisVisitor::visit_local");
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

        // Removed incorrect reference to prime_vector_for_declaration
        // *prime_vector_for_declaration.map.entry(self.prime_morphism.get_prime_for_component(svg_hir::keys::PREDICATE_PRIME_RESONANCE)).or_insert(0) += 1; // Mark resonance

        visit::visit_local(self, i);
    }

    fn visit_fn_arg(&mut self, i: &'ast syn::FnArg) {
        // eprintln!("DEBUG: AnalysisVisitor::visit_fn_arg");
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
        // Removed incorrect reference to prime_vector_for_declaration
        // *prime_vector_for_declaration.map.entry(self.prime_morphism.get_prime_for_component(svg_hir::keys::PREDICATE_PRIME_RESONANCE)).or_insert(0) += 1; // Mark resonance
        visit::visit_fn_arg(self, i);
    }
}