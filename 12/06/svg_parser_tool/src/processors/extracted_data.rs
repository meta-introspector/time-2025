use std::collections::HashMap;
use std::path::PathBuf;
use serde::{Serialize, Deserialize};

use monster_svg_morphism::analysis_report::AnalysisReport;
use crate::processors::term::{Term, TermType}; // Adjusted import path
use crate::processors::relationship::{Relationship, RelationshipType}; // Adjusted import path
use svg_hir::prime_vector::PrimeVector;

// Define the primes to analyze (same as in wordcloud_generator.rs)
pub const PRIMES_TO_ANALYZE: &[u64] = &[
    2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71,
];

/// Aggregates all extracted terms and relationships.
#[derive(Debug, Serialize, Deserialize)]
pub struct ExtractedData {
    pub terms: HashMap<String, Term>, // Term name to Term struct
    pub relationships: Vec<Relationship>,
    pub rust_analysis_reports: HashMap<String, AnalysisReport>, // Store raw reports for now
    pub prime_power_counts: HashMap<u64, u64>, // Stores total exponent for each prime
}


impl ExtractedData {
    pub fn new() -> Self {
        ExtractedData {
            terms: HashMap::new(),
            relationships: Vec::new(),
            rust_analysis_reports: HashMap::new(),
            prime_power_counts: HashMap::new(),
        }
    }

    /// Adds or updates a term, incrementing frequency if already present.
    pub fn add_term(&mut self, term: Term) {
        // If the term has a PrimeVector, add its powers to the total counts
        if let Some(ref pv) = term.prime_vector {
            for (&prime, &exponent) in &pv.map {
                *self.prime_power_counts.entry(prime).or_insert(0) += exponent;
            }
        }

        self.terms.entry(term.name.clone())
            .and_modify(|e| {
                e.frequency += 1;
                // If an existing term is updated, and it now has a PrimeVector, add its powers
                if e.prime_vector.is_none() && term.prime_vector.is_some() {
                    e.prime_vector = term.prime_vector.clone();
                    if let Some(ref pv) = e.prime_vector {
                        for (&prime, &exponent) in &pv.map {
                            *self.prime_power_counts.entry(prime).or_insert(0) += exponent;
                        }
                    }
                }
            })
            .or_insert(term);
    }

    /// Adds a relationship.
    pub fn add_relationship(&mut self, relationship: Relationship) {
        self.relationships.push(relationship);
    }

    /// Merges an AnalysisReport into the extracted data.
    pub fn merge_rust_report(&mut self, project_path: String, report: AnalysisReport) {
        // Extract terms from symbol table
        for (symbol_name, prime_vector) in &report.symbol_table {
            self.add_term(Term {
                name: symbol_name.clone(),
                source_file: PathBuf::from(&project_path), // Placeholder for actual file
                term_type: TermType::RustSymbol,
                prime_vector: Some(prime_vector.clone()),
                frequency: 1, // Will be updated if term appears multiple times
            });
            // TODO: Also extract relations from symbol_table (e.g., module::struct)
        }

        // Extract terms and relationships from prime_occurrences
        for (_prime, occurrences) in &report.prime_occurrences {
            // Treat prime as a property, the actual term is the occurrence
            for occurrence in occurrences {
                self.add_term(Term {
                    name: occurrence.clone(),
                    source_file: PathBuf::from(&project_path),
                    term_type: TermType::RustKeyword, // Or more specific if known
                    prime_vector: None, // Or derived from the prime if it represents a direct term
                    frequency: 1,
                });
            }
        }
        
        // Extract recursive function relationships
        for func_name in &report.recursive_functions {
            self.add_relationship(Relationship {
                source_term_name: func_name.clone(),
                target_term_name: func_name.clone(), // Self-referential for direct recursion
                rel_type: RelationshipType::RustCall,
                prime_vector: None, // Or a prime representing recursion
            });
        }

        // Extract recursive cycles
        for (caller, cycle_path) in &report.recursive_cycles {
            if let Some(first_in_cycle) = cycle_path.first() {
                self.add_relationship(Relationship {
                    source_term_name: caller.clone(),
                    target_term_name: first_in_cycle.clone(), // Link caller to start of cycle
                    rel_type: RelationshipType::RustCall,
                    prime_vector: None, // Or a prime representing cycle
                });
            }
            for i in 0..cycle_path.len() {
                let source = &cycle_path[i];
                let target = &cycle_path[(i + 1) % cycle_path.len()];
                self.add_relationship(Relationship {
                    source_term_name: source.clone(),
                    target_term_name: target.clone(),
                    rel_type: RelationshipType::RustCall,
                    prime_vector: None, // Or a prime representing cycle link
                });
            }
        }
        
        // Store the raw report as well
        self.rust_analysis_reports.insert(project_path, report);
    }
}
