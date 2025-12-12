use std::collections::HashMap;
use std::path::PathBuf;
use serde::{Serialize, Deserialize};

use monster_svg_morphism::analysis_report::AnalysisReport;
use svg_hir::prime_vector::PrimeVector;

/// Represents a file along with its content for caching purposes.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FileEntry {
    pub path: PathBuf,
    pub content: Vec<u8>,
}

/// Represents a single extracted term or concept.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Term {
    pub name: String,
    pub source_file: PathBuf,
    pub term_type: TermType,
    pub prime_vector: Option<PrimeVector>, // Optional as not all terms might have one
    // Add fields for visual properties that will be derived later
    pub frequency: usize,
}

/// Categorization of terms.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq, Hash)]
pub enum TermType {
    RustSymbol,
    RustKeyword,
    SvgElement,
    SvgAttribute,
    SvgText,
    JsonPath,
    JsonValue,
    MarkdownHeading,
    MarkdownKeyword, // For significant words in markdown
    ConfigKey,       // For Cargo.toml, settings.toml
    NixExpression,
    Other,
}

/// Represents a directed relationship between two terms.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Relationship {
    pub source_term_name: String,
    pub target_term_name: String,
    pub rel_type: RelationshipType,
    pub prime_vector: Option<PrimeVector>, // Represents the nature of the relationship
    // Add fields for visual properties like arrow color, line style, etc.
}

/// Categorization of relationships.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq, Eq, Hash)]
pub enum RelationshipType {
    RustCall,
    RustStructField,
    RustEnumVariant,
    RustImpl,
    RustInheritance, // Trait implementation
    SvgHierarchy,    // Parent-child element
    SvgReference,    // xlink:href, url()
    JsonNesting,     // Key-value, array element
    ConfigDependency, // e.g., Cargo.toml deps
    SemanticLink,    // e.g., explicit link in Markdown, or derived from text
    Other,
}

/// Aggregates all extracted terms and relationships.
#[derive(Debug, Serialize, Deserialize)]
pub struct ExtractedData {
    pub terms: HashMap<String, Term>, // Term name to Term struct
    pub relationships: Vec<Relationship>,
    pub rust_analysis_reports: HashMap<String, AnalysisReport>, // Store raw reports for now
}

impl ExtractedData {
    pub fn new() -> Self {
        ExtractedData {
            terms: HashMap::new(),
            relationships: Vec::new(),
            rust_analysis_reports: HashMap::new(),
        }
    }

    /// Adds or updates a term, incrementing frequency if already present.
    pub fn add_term(&mut self, term: Term) {
        self.terms.entry(term.name.clone())
            .and_modify(|e| e.frequency += 1)
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
