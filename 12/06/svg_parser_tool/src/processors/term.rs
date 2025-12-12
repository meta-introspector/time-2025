use std::path::PathBuf;
use serde::{Serialize, Deserialize};
use svg_hir::prime_vector::PrimeVector;

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
