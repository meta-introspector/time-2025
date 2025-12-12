use std::path::PathBuf;
use serde::{Serialize, Deserialize};
use svg_hir::prime_vector::PrimeVector;

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
