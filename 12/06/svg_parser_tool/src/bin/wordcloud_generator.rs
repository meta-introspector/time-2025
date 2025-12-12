use std::env;
use std::path::PathBuf;
use walkdir::WalkDir;
use std::collections::{HashMap, HashSet};
use std::io::Read;
use std::fs;

use monster_svg_morphism::analyzer::run_analysis;
use monster_svg_morphism::analysis_report::AnalysisReport;
use svg_parser_tool::processors::{ExtractedData, FileEntry, Term, TermType, Relationship, RelationshipType};
use usvg::Tree; // Add usvg for SVG parsing
use xmlwriter::XmlWriter; // Add xmlwriter, might be used by usvg or for xml parsing
use rocksdb::{DB, Options}; // Import rocksdb
use sha2::{Sha256, Digest}; // Import sha2 for hashing
use serde_json; // Import serde_json for (de)serialization

// Define the primes to analyze
const PRIMES_TO_ANALYZE: &[u64] = &[
    2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97,
    101, 103, 107, 109, 113,
];

// Define the RocksDB cache directory
const ROCKSDB_CACHE_DIR: &str = "C:\\Users\\gentd\\.gemini\\tmp\\wordcloud_cache"; // Use the project's temporary directory, adjust if needed

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let args: Vec<String> = env::args().collect();
    let root_path_str = args.get(1).map_or(".", |s| s);

    let root_path = PathBuf::from(root_path_str);

    println!("Collecting files from: {}", root_path.display());

    // Initialize RocksDB
    let db = DB::open_default(ROCKSDB_CACHE_DIR)?;
    println!("RocksDB opened at: {}", ROCKSDB_CACHE_DIR);

    let mut all_files: Vec<FileEntry> = Vec::new();
    let mut rs_files: Vec<FileEntry> = Vec::new();
    let mut svg_files: Vec<FileEntry> = Vec::new();
    let mut json_files: Vec<FileEntry> = Vec::new();
    let mut lock_files: Vec<FileEntry> = Vec::new();
    let mut nix_files: Vec<FileEntry> = Vec::new();
    let mut cargo_toml_files: Vec<FileEntry> = Vec::new();
    let mut settings_toml_files: Vec<FileEntry> = Vec::new();
    let mut md_files: Vec<FileEntry> = Vec::new();
    let mut org_files: Vec<FileEntry> = Vec::new();


    for entry in WalkDir::new(&root_path)
        .into_iter()
        .filter_map(|e| e.ok())
        .filter(|e| e.file_type().is_file()) // Only process files
    {
        let path = entry.path().to_path_buf();
        let file_hash_key = format!("file_content_hash:{}", path.to_string_lossy());
        let file_content: Vec<u8>;

        if let Some(cached_content_bytes) = db.get(&file_hash_key)? {
            file_content = cached_content_bytes;
            // eprintln!("Loaded content for {} from cache.", path.display());
        } else {
            // Read file from filesystem
            let mut file = fs::File::open(&path)?;
            let mut buffer = Vec::new();
            file.read_to_end(&mut buffer)?;
            file_content = buffer;
            // Cache raw file content
            db.put(&file_hash_key, &file_content)?;
            // eprintln!("Read content for {} from filesystem and cached it.", path.display());
        }

        let file_entry = FileEntry { path: path.clone(), content: file_content };
        all_files.push(file_entry.clone());

        if let Some(extension) = path.extension() {
            match extension.to_str() {
                Some("rs") => rs_files.push(file_entry),
                Some("svg") => svg_files.push(file_entry),
                Some("json") => json_files.push(file_entry),
                Some("lock") => lock_files.push(file_entry),
                Some("nix") => nix_files.push(file_entry),
                Some("toml") => {
                    if let Some(file_name) = path.file_name().and_then(|f| f.to_str()) {
                        if file_name == "Cargo.toml" {
                            cargo_toml_files.push(file_entry);
                        } else if file_name == "settings.toml" {
                            settings_toml_files.push(file_entry);
                        }
                    }
                },
                Some("md") => md_files.push(file_entry),
                Some("org") => org_files.push(file_entry),
                _ => {},
            }
        }
    }

    println!("Found {} total files.", all_files.len());
    println!("Found {} Rust files.", rs_files.len());
    println!("Found {} SVG files.", svg_files.len());
    println!("Found {} JSON files.", json_files.len());
    println!("Found {} Lock files.", lock_files.len());
    println!("Found {} Nix files.", nix_files.len());
    println!("Found {} Cargo.toml files.", cargo_toml_files.len());
    println!("Found {} settings.toml files.", settings_toml_files.len());
    println!("Found {} Markdown files.", md_files.len());
    println!("Found {} Org-mode files.", org_files.len());

    let mut extracted_data = ExtractedData::new();

    // Process Rust files
    // Use the `cargo_toml_files` (now as FileEntry) to identify project roots
    let project_roots = identify_project_roots(cargo_toml_files.iter().map(|fe| fe.path.clone()).collect());

    for project_root in project_roots {
        eprintln!("Running analysis for Rust project: {}", project_root.display());
        
        // Generate cache key for project based on all rs files within it
        let project_rs_files: Vec<&FileEntry> = rs_files.iter()
            .filter(|fe| fe.path.starts_with(&project_root))
            .collect();
        let cache_key = get_project_analysis_cache_key(&project_root, &project_rs_files)?;

        if let Some(cached_report_bytes) = db.get(&cache_key)? {
            let cached_report: AnalysisReport = serde_json::from_slice(&cached_report_bytes)?;
            extracted_data.merge_rust_report(project_root.display().to_string(), cached_report);
            eprintln!("Loaded Rust analysis for {} from cache.", project_root.display());
        } else {
            let report = run_analysis(&project_root, PRIMES_TO_ANALYZE);
            let serialized_report = serde_json::to_vec(&report)?;
            db.put(&cache_key, serialized_report)?;
            extracted_data.merge_rust_report(project_root.display().to_string(), report);
            eprintln!("Ran Rust analysis for {} and cached it.", project_root.display());
        }
    }
    // TODO: Process SVG files using `svg_files`
    // TODO: Process JSON files using `json_files`
    // TODO: Process other file types (lock, nix, settings.toml, md, org)

    // Example: Print some extracted data
    println!("Total terms extracted: {}", extracted_data.terms.len());
    println!("Total relationships extracted: {}", extracted_data.relationships.len());


    Ok(())
}

// Helper to identify unique, non-nested project roots from Cargo.toml paths
// This function needs to be adjusted as we now pass the collected Cargo.toml paths directly
fn identify_project_roots(cargo_toml_paths: Vec<PathBuf>) -> Vec<PathBuf> {
    let mut project_roots: HashSet<PathBuf> = HashSet::new();
    let mut candidate_roots: Vec<PathBuf> = cargo_toml_paths
        .into_iter()
        .filter_map(|p| p.parent().map(|parent| parent.to_path_buf()))
        .collect();
    
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

// Function to calculate SHA256 hash of a file's content
fn calculate_file_content_hash(content: &[u8]) -> String {
    let mut hasher = Sha256::new();
    hasher.update(content);
    format!("{:x}", hasher.finalize())
}

// Function to generate a unique cache key for a Rust project's analysis report
// This key combines the project root path and hashes of all relevant Rust files' contents.
fn get_project_analysis_cache_key(project_root: &PathBuf, rs_files: &[&FileEntry]) -> Result<String, Box<dyn std::error::Error>> {
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