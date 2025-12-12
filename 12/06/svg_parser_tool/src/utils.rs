use std::path::PathBuf;
// Removed unused import: use std::collections::HashSet;
use sha2::{Sha256, Digest};
use crate::processors::{FileEntry};

// Function to calculate SHA256 hash of a file's content
pub fn calculate_file_content_hash(content: &[u8]) -> String {
    let mut hasher = Sha256::new();
    hasher.update(content);
    format!("{:x}", hasher.finalize())
}

// Function to generate a unique cache key for a Rust project's analysis report
// This key combines the project root path and hashes of all relevant Rust files' contents.
pub fn get_project_analysis_cache_key(project_root: &PathBuf, rs_files: &[&FileEntry]) -> Result<String, Box<dyn std::error::Error>> {
    let mut hasher = Sha256::new();
    hasher.update(project_root.to_string_lossy().as_bytes());

    let mut file_content_hashes: Vec<String> = Vec::new();
    for file_entry in rs_files {
        // Use the content hash
        file_content_hashes.push(calculate_file_content_hash(&file_entry.content));
    }
    // Sort file hashes to ensure a consistent key regardless of file system iteration order
    file_content_hashes.sort();

    for hash in file_content_hashes {
        hasher.update(hash.as_bytes());
    }

    Ok(format!("rust_analysis_report:{}", calculate_file_content_hash(&hasher.finalize())))
}

// Helper to identify unique, non-nested project roots from Cargo.toml paths
pub fn identify_project_roots(cargo_toml_paths: Vec<PathBuf>) -> Vec<PathBuf> {
    let mut candidate_roots: Vec<PathBuf> = cargo_toml_paths
        .into_iter()
        .filter_map(|p| p.parent().map(|parent| parent.to_path_buf()))
        .collect();
    
    // Sort to handle parent directories first for proper nesting checks
    candidate_roots.sort_by(|a, b| a.cmp(b));

    let mut final_roots: Vec<PathBuf> = Vec::new();

    for candidate in candidate_roots {
        let mut is_nested = false;
        for existing_root in &final_roots {
            if candidate.starts_with(existing_root) && candidate != *existing_root {
                is_nested = true;
                break;
            }
        }
        if !is_nested {
            final_roots.push(candidate);
        }
    }
    final_roots
}

// Function to calculate a master cache key for the aggregated ExtractedData
// This key is derived from the root path and the hashes of all relevant file contents.
pub fn calculate_master_cache_key(root_path: &PathBuf, all_file_entries: &[FileEntry]) -> String {
    let mut hasher = Sha256::new();
    hasher.update(root_path.to_string_lossy().as_bytes());

    let mut file_path_and_content_hashes: Vec<String> = Vec::new();
    for file_entry in all_file_entries {
        let file_path_str = file_entry.path.to_string_lossy().to_string();
        let file_content_hash = calculate_file_content_hash(&file_entry.content);
        file_path_and_content_hashes.push(format!("{}:{}", file_path_str, file_content_hash));
    }
    file_path_and_content_hashes.sort(); // Ensure consistent key regardless of iteration order

    for item in file_path_and_content_hashes {
        hasher.update(item.as_bytes());
    }

    format!("aggregated_extracted_data:{}", calculate_file_content_hash(&hasher.finalize()))
}
