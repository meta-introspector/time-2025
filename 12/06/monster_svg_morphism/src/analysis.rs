// src/analysis.rs
use std::collections::HashMap;
use std::fs;
use std::path::PathBuf;
use syn::{File, Item, Lit, Expr};
use syn::visit::{self, Visit};
use walkdir::WalkDir;

pub struct AnalysisReport {
    pub prime_occurrences: HashMap<u64, Vec<String>>, // Renamed from seventy_one_occurrences
    pub prime_factor_occurrences: HashMap<u64, Vec<String>>,
    pub recursive_functions: Vec<String>, // Direct recursion
    pub recursive_cycles: Vec<(String, Vec<String>)>, // (Starting function, Cycle path)
}

struct PrimeFactorizer;

impl PrimeFactorizer {
    fn get_prime_factors(n: u64) -> Vec<u64> {
        let mut factors = Vec::new();
        let mut d = 2;
        let mut num = n;

        while d * d <= num {
            while num % d == 0 {
                factors.push(d);
                num /= d;
            }
            d += 1;
        }
        if num > 1 {
            factors.push(num);
        }
        factors
    }
}

struct AnalysisVisitor<'a> {
    prime_occurrences: HashMap<u64, Vec<String>>,
    prime_factor_occurrences: HashMap<u64, Vec<String>>,
    recursive_functions: Vec<String>,
    current_function: Option<String>,
    function_calls: HashMap<String, Vec<String>>,
    primes_to_analyze: &'a [u64], // Configurable list of primes
}

impl<'ast, 'a> visit::Visit<'ast> for AnalysisVisitor<'a> {
    fn visit_item_fn(&mut self, i: &'ast syn::ItemFn) {
        let function_name = i.sig.ident.to_string();
        self.current_function = Some(function_name.clone());
        visit::visit_item_fn(self, i);
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
                let size = item_enum.variants.len() as u64;
                if self.primes_to_analyze.contains(&size) {
                    self.prime_occurrences.entry(size).or_default().push(format!(
                        "Enum '{}' has {} variants.",
                        item_enum.ident, size
                    ));
                }
            }
            Item::Struct(item_struct) => {
                let size = item_struct.fields.len() as u64;
                if self.primes_to_analyze.contains(&size) {
                    self.prime_occurrences.entry(size).or_default().push(format!(
                        "Struct '{}' has {} fields.",
                        item_struct.ident, size
                    ));
                }
            }
            Item::Mod(item_mod) => {
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
                            "Module '{}' has {} public functions.",
                            item_mod.ident, public_fns
                        ));
                    }
                }
            }
            Item::Fn(item_fn) => {
                let param_count = item_fn.sig.inputs.len() as u64;
                if self.primes_to_analyze.contains(&param_count) {
                    self.prime_occurrences.entry(param_count).or_default().push(format!(
                        "Function '{}' has {} parameters.",
                        item_fn.sig.ident, param_count
                    ));
                }
            }
            Item::Const(item_const) => {
                if let syn::Expr::Lit(expr_lit) = &*item_const.expr {
                    if let Lit::Str(lit_str) = &expr_lit.lit {
                        let s = lit_str.value();
                        let len = s.len() as u64;
                        if self.primes_to_analyze.contains(&len) {
                            self.prime_occurrences.entry(len).or_default().push(format!(
                                "String literal in const '{}' has length {}.",
                                item_const.ident, len
                            ));
                        }
                        // Prime factorization of ASCII sum
                        let ascii_sum: u64 = s.bytes().map(|b| b as u64).sum();
                        if ascii_sum > 1 {
                            for factor in PrimeFactorizer::get_prime_factors(ascii_sum) {
                                self.prime_factor_occurrences
                                    .entry(factor)
                                    .or_default()
                                    .push(format!(
                                        "Const '{}' string ASCII sum has prime factor {}.",
                                        item_const.ident, factor
                                    ));
                            }
                        }
                    } else if let Lit::Int(lit_int) = &expr_lit.lit {
                        if let Ok(num) = lit_int.base10_parse::<u64>() {
                            if self.primes_to_analyze.contains(&num) {
                                self.prime_occurrences.entry(num).or_default().push(format!(
                                    "Found numeric literal {} in const '{}'.",
                                    num, item_const.ident
                                ));
                            }
                            if num > 1 {
                                for factor in PrimeFactorizer::get_prime_factors(num) {
                                    self.prime_factor_occurrences
                                        .entry(factor)
                                        .or_default()
                                        .push(format!(
                                            "Const '{}' numeric literal has prime factor {}.",
                                            item_const.ident, factor
                                        ));
                                }
                            }
                        }
                    }
                }
            }
            _ => {}
        }
        visit::visit_item(self, item);
    }
    
    // Also visit expressions for standalone literals outside of consts
    fn visit_expr(&mut self, expr: &'ast Expr) {
        if let Expr::Lit(expr_lit) = expr {
            if let Lit::Int(lit_int) = &expr_lit.lit {
                if let Ok(num) = lit_int.base10_parse::<u64>() {
                    if self.primes_to_analyze.contains(&num) {
                        self.prime_occurrences.entry(num).or_default().push(format!("Found numeric literal {}.", num));
                    }
                    if num > 1 {
                        for factor in PrimeFactorizer::get_prime_factors(num) {
                            self.prime_factor_occurrences
                                .entry(factor)
                                .or_default()
                                .push(format!("Numeric literal has prime factor {}.", factor));
                        }
                    }
                }
            } else if let Lit::Str(lit_str) = &expr_lit.lit {
                let s = lit_str.value();
                let len = s.len() as u64;
                if self.primes_to_analyze.contains(&len) {
                    self.prime_occurrences.entry(len).or_default().push(format!("Found string literal with length {}.", len));
                }
                let ascii_sum: u64 = s.bytes().map(|b| b as u64).sum();
                if ascii_sum > 1 {
                    for factor in PrimeFactorizer::get_prime_factors(ascii_sum) {
                        self.prime_factor_occurrences
                            .entry(factor)
                            .or_default()
                            .push(format!("String literal ASCII sum has prime factor {}.", factor));
                    }
                }
            }
        }
        visit::visit_expr(self, expr);
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
    let mut visitor = AnalysisVisitor {
        prime_occurrences: HashMap::new(),
        prime_factor_occurrences: HashMap::new(),
        recursive_functions: Vec::new(),
        current_function: None,
        function_calls: HashMap::new(),
        primes_to_analyze,
    };

    for entry in WalkDir::new(path)
        .into_iter()
        .filter_map(|e| e.ok())
        .filter(|e| e.path().extension().map_or(false, |s| s == "rs"))
    {
        let path = entry.path();
        let content = match fs::read_to_string(path) {
            Ok(c) => c,
            Err(_) => continue,
        };

        let ast: File = match syn::parse_file(&content) {
            Ok(a) => a,
            Err(e) => {
                eprintln!("Error parsing file {}: {}", path.display(), e);
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
    let mut path: Vec<String> = Vec::new();

    for function_name in visitor.function_calls.keys() {
        if !visited.get(function_name).unwrap_or(&false) {
            find_cycles_dfs(
                &visitor.function_calls,
                function_name,
                &mut visited,
                &mut recursion_stack,
                &mut path,
                &mut all_recursive_cycles,
                primes_to_analyze,
            );
        }
    }

    AnalysisReport {
        prime_occurrences: visitor.prime_occurrences,
        prime_factor_occurrences: visitor.prime_factor_occurrences,
        recursive_functions: visitor.recursive_functions,
        recursive_cycles: all_recursive_cycles,
    }
}