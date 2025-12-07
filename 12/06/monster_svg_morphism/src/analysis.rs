// src/analysis.rs
use std::collections::HashMap;
use std::fs;
use std::path::PathBuf;
use syn::{File, Item, Lit, Expr};
use syn::visit::{self, Visit}; // Import the entire visit module AND the Visit trait
use walkdir::WalkDir;

pub struct AnalysisReport {
    pub seventy_one_occurrences: Vec<String>,
    pub prime_factor_occurrences: HashMap<u64, Vec<String>>,
    pub recursive_functions: Vec<String>,
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

struct AnalysisVisitor {
    seventy_one_occurrences: Vec<String>,
    prime_factor_occurrences: HashMap<u64, Vec<String>>,
    recursive_functions: Vec<String>,
    current_function: Option<String>,
    function_calls: HashMap<String, Vec<String>>,
}

impl<'ast> visit::Visit<'ast> for AnalysisVisitor { // Use fully qualified path for the trait
    fn visit_item_fn(&mut self, i: &'ast syn::ItemFn) {
        let function_name = i.sig.ident.to_string();
        self.current_function = Some(function_name.clone());
        visit::visit_item_fn(self, i); // Use fully qualified path for the function
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
        visit::visit_expr_call(self, i); // Use fully qualified path for the function
    }

    fn visit_item(&mut self, item: &'ast Item) {
        match item {
            Item::Enum(item_enum) => {
                if item_enum.variants.len() == 71 {
                    self.seventy_one_occurrences.push(format!(
                        "Enum '{}' has 71 variants.",
                        item_enum.ident
                    ));
                }
            }
            Item::Struct(item_struct) => {
                if item_struct.fields.len() == 71 {
                    self.seventy_one_occurrences.push(format!(
                        "Struct '{}' has 71 fields.",
                        item_struct.ident
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
                        .count();
                    if public_fns == 71 {
                        self.seventy_one_occurrences.push(format!(
                            "Module '{}' has 71 public functions.",
                            item_mod.ident
                        ));
                    }
                }
            }
            Item::Fn(item_fn) => {
                if item_fn.sig.inputs.len() == 71 {
                    self.seventy_one_occurrences.push(format!(
                        "Function '{}' has 71 parameters.",
                        item_fn.sig.ident
                    ));
                }
            }
            Item::Const(item_const) => {
                if let syn::Expr::Lit(expr_lit) = &*item_const.expr {
                    if let Lit::Str(lit_str) = &expr_lit.lit {
                        let s = lit_str.value();
                        if s.len() == 71 {
                            self.seventy_one_occurrences.push(format!(
                                "String literal in const '{}' has length 71.",
                                item_const.ident
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
                        if lit_int.to_string() == "71" {
                            self.seventy_one_occurrences
                                .push(format!("Found numeric literal 71 in const '{}'.", item_const.ident));
                        }
                        if let Ok(num) = lit_int.base10_parse() {
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
        visit::visit_item(self, item); // Use fully qualified path for the function
    }
    
    // Also visit expressions for standalone literals outside of consts
    fn visit_expr(&mut self, expr: &'ast Expr) {
        if let Expr::Lit(expr_lit) = expr {
            if let Lit::Int(lit_int) = &expr_lit.lit {
                if lit_int.to_string() == "71" {
                    self.seventy_one_occurrences.push(format!("Found numeric literal 71."));
                }
                if let Ok(num) = lit_int.base10_parse() {
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
                if s.len() == 71 {
                    self.seventy_one_occurrences.push(format!("Found string literal with length 71."));
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
        visit::visit_expr(self, expr); // Use fully qualified path for the function
    }
}


pub fn run_analysis(path: &PathBuf) -> AnalysisReport {
    let mut visitor = AnalysisVisitor {
        seventy_one_occurrences: Vec::new(),
        prime_factor_occurrences: HashMap::new(),
        recursive_functions: Vec::new(),
        current_function: None,
        function_calls: HashMap::new(),
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
    for (caller, callees) in &visitor.function_calls {
        if callees.contains(caller) {
            visitor.recursive_functions.push(caller.clone());
        }
    }

    AnalysisReport {
        seventy_one_occurrences: visitor.seventy_one_occurrences,
        prime_factor_occurrences: visitor.prime_factor_occurrences,
        recursive_functions: visitor.recursive_functions,
    }
}

// TODO: Recursion depth analysis with prime limits (optional)
// TODO: Integration with monster_svg_morphism main.rs for reporting.
// TODO: Create keys.rs with string constants for prime factorization.