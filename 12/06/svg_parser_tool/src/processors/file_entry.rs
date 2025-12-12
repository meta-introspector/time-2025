use std::path::PathBuf;
use serde::{Serialize, Deserialize};

/// Represents a file along with its content for caching purposes.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct FileEntry {
    pub path: PathBuf,
    pub content: Vec<u8>,
}
