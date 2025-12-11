use std::env;
use std::path::{Path, PathBuf};
use walkdir::WalkDir;
use serde::{Serialize, Deserialize};
use monster_svg_morphism::analysis::{run_analysis, AnalysisReport};
use std::collections::{HashMap, HashSet};

// Define a structure to hold the results of all analyses
#[derive(Debug, Serialize, Deserialize)]
struct GlobalAnalysisResult {
    #[serde(flatten)]
    reports: HashMap<String, AnalysisReport>, // Use HashMap to store reports by project path
}

// Define the primes to analyze
const PRIMES_TO_ANALYZE: &[u64] = &[
    2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97,
    101, 103, 107, 109, 113,
];

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let args: Vec<String> = env::args().collect();
    let root_path_str = args.get(1).map_or(".", |s| s); // Use current dir if no arg

    let root_path = PathBuf::from(root_path_str);
    
    let cargo_toml_paths = find_cargo_tomls(&root_path);
    let project_roots = identify_project_roots(cargo_toml_paths);

    let mut all_analysis_results = HashMap::new();

    for project_root in project_roots {
        eprintln!("Running analysis for Rust project: {}", project_root.display());
        let report = run_analysis(&project_root, PRIMES_TO_ANALYZE);
        all_analysis_results.insert(project_root.display().to_string(), report);
    }

    let global_result = GlobalAnalysisResult {
        reports: all_analysis_results,
    };

    let json_output = serde_json::to_string_pretty(&global_result)?;
    println!("{}", json_output);

    Ok(())
}

// Helper to find all Cargo.toml files
fn find_cargo_tomls(root: &Path) -> Vec<PathBuf> {
    WalkDir::new(root)
        .into_iter()
        .filter_map(|e| e.ok())
        .filter(|e| e.file_name() == "Cargo.toml")
        .map(|e| e.into_path())
        .collect()
}

// Helper to identify unique, non-nested project roots from Cargo.toml paths
fn identify_project_roots(cargo_toml_paths: Vec<PathBuf>) -> Vec<PathBuf> {
    let mut project_roots: HashSet<PathBuf> = HashSet::new();
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