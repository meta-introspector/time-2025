use std::path::PathBuf;
use ignore::{WalkBuilder};
use std::io::Read;
use std::fs;

use monster_svg_morphism::analyzer::run_analysis;
use svg_parser_tool::processors::{ExtractedData, FileEntry, PRIMES_TO_ANALYZE, process_svg_file};
use rocksdb::{DB};
use serde_json;
use pico_args::Arguments;

use svg_parser_tool::utils::{calculate_master_cache_key, identify_project_roots, calculate_file_content_hash, get_project_analysis_cache_key};


// Define the RocksDB cache directory
const ROCKSDB_CACHE_DIR: &str = "C:\\Users\\gentd\\.gemini\\tmp\\wordcloud_cache";

fn print_help() {
    println!(
        r#"wordcloud_generator
Usage: wordcloud_generator [PATH]

Arguments:
  [PATH]    The root directory to start collecting files from. Defaults to current directory.

Options:
  -h, --help    Print help information
"#
    );
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let mut args = Arguments::from_env();

    // Check for --help or -h
    if args.contains(["-h", "--help"]) {
        print_help();
        return Ok(());
    }

    let root_path_str: String = args.free_from_str().unwrap_or_else(|_| ".".to_string());
    let root_path = PathBuf::from(root_path_str);

    // Initialize RocksDB
    let db = DB::open_default(ROCKSDB_CACHE_DIR)?;
    println!("RocksDB opened at: {}", ROCKSDB_CACHE_DIR);

    let mut extracted_data: ExtractedData;

    let all_file_entries = collect_all_file_entries(&root_path, &db)?;

    let master_cache_key = calculate_master_cache_key(&root_path, &all_file_entries);

    // Attempt to load aggregated ExtractedData from cache
    match db.get(&master_cache_key)? {
        Some(cached_data_bytes) => {
            match serde_json::from_slice(&cached_data_bytes) {
                Ok(loaded_data) => {
                    extracted_data = loaded_data;
                    eprintln!("Cache HIT for aggregated ExtractedData. Loaded from RocksDB.");
                },
                Err(e) => {
                    eprintln!("Cache DECODE ERROR for aggregated ExtractedData: {}. Re-processing all files. Bytes: {:?}", e, cached_data_bytes);
                    extracted_data = ExtractedData::new(); // Reset and re-process
                    process_all_files(&root_path, &db, &all_file_entries, &mut extracted_data)?;
                    let serialized_extracted_data = serde_json::to_vec(&extracted_data)?;
                    db.put(&master_cache_key, serialized_extracted_data)?;
                    eprintln!("Re-processed all files and cached aggregated ExtractedData.");
                }
            }
        },
        None => {
            eprintln!("Cache MISS for aggregated ExtractedData. Processing all files.");
            extracted_data = ExtractedData::new();
            process_all_files(&root_path, &db, &all_file_entries, &mut extracted_data)?;
            let serialized_extracted_data = serde_json::to_vec(&extracted_data)?;
            db.put(&master_cache_key, serialized_extracted_data)?;
            eprintln!("Processed all files and cached aggregated ExtractedData.");
        }
    }

    // Example: Print some extracted data
    println!("Total terms extracted: {}", extracted_data.terms.len());
    println!("Total relationships extracted: {}", extracted_data.relationships.len());
    
    println!("Running prime power counts:");
    for &prime in PRIMES_TO_ANALYZE {
        if let Some(&count) = extracted_data.prime_power_counts.get(&prime) {
            println!("  Prime {}: {}", prime, count);
        }
    }

    Ok(())
}

fn collect_all_file_entries(root_path: &PathBuf, db: &DB) -> Result<Vec<FileEntry>, Box<dyn std::error::Error>> {
    let mut all_file_entries: Vec<FileEntry> = Vec::new();
    println!("Scanning files from: {}", root_path.display());

    for result in WalkBuilder::new(&root_path).git_ignore(true).build() {
        let entry = match result {
            Ok(entry) => entry,
            Err(e) => {
                eprintln!("Error walking directory: {}", e);
                continue;
            }
        };

        if !entry.file_type().map_or(false, |ft| ft.is_file()) {
            continue; // Only process files
        }

        let path = entry.path().to_path_buf();
        let file_content: Vec<u8>;
        
        // Always read file content to compute its hash, either from cache or filesystem
        let file_content_cache_key = format!("file_content_hash:{}", path.to_string_lossy());
        if let Some(cached_content_bytes) = db.get(&file_content_cache_key)? {
            file_content = cached_content_bytes;
        } else {
            let mut file = fs::File::open(&path)?;
            let mut buffer = Vec::new();
            file.read_to_end(&mut buffer)?;
            file_content = buffer;
            db.put(&file_content_cache_key, &file_content)?;
        }
        
        all_file_entries.push(FileEntry { path, content: file_content });
    }
    Ok(all_file_entries)
}

fn process_all_files(
    _root_path: &PathBuf,
    db: &DB,
    all_file_entries: &[FileEntry],
    extracted_data: &mut ExtractedData
) -> Result<(), Box<dyn std::error::Error>> {
    let mut rs_files: Vec<&FileEntry> = Vec::new();
    let mut svg_files: Vec<&FileEntry> = Vec::new();
    let mut json_files: Vec<&FileEntry> = Vec::new();
    let mut lock_files: Vec<&FileEntry> = Vec::new();
    let mut nix_files: Vec<&FileEntry> = Vec::new();
    let mut cargo_toml_files: Vec<&FileEntry> = Vec::new();
    let mut settings_toml_files: Vec<&FileEntry> = Vec::new();
    let mut md_files: Vec<&FileEntry> = Vec::new();
    let mut org_files: Vec<&FileEntry> = Vec::new();

    for file_entry in all_file_entries {
        if let Some(extension) = file_entry.path.extension() {
            match extension.to_str() {
                Some("rs") => rs_files.push(file_entry),
                Some("svg") => svg_files.push(file_entry),
                Some("json") => json_files.push(file_entry),
                Some("lock") => lock_files.push(file_entry),
                Some("nix") => nix_files.push(file_entry),
                Some("toml") => {
                    if let Some(file_name) = file_entry.path.file_name().and_then(|f| f.to_str()) {
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

    println!("Found {} total files.", all_file_entries.len());
    println!("Found {} Rust files.", rs_files.len());
    println!("Found {} SVG files.", svg_files.len());
    println!("Found {} JSON files.", json_files.len());
    println!("Found {} Lock files.", lock_files.len());
    println!("Found {} Nix files.", nix_files.len());
    println!("Found {} Cargo.toml files.", cargo_toml_files.len());
    println!("Found {} settings.toml files.", settings_toml_files.len());
    println!("Found {} Markdown files.", md_files.len());
    println!("Found {} Org-mode files.", org_files.len());

    // Process Rust files
    // Use the `cargo_toml_files` (now as FileEntry) to identify project roots
    let project_roots = identify_project_roots(cargo_toml_files.iter().map(|fe| fe.path.clone()).collect());

    for project_root in project_roots {
        eprintln!("Running analysis for Rust project: {}", project_root.display());
        
        // Generate cache key for project based on all rs files within it
        let project_rs_files: Vec<&FileEntry> = rs_files.iter()
            .filter(|fe| fe.path.starts_with(&project_root))
            .cloned() // Add .cloned() here to resolve the `&&FileEntry` to `&FileEntry` issue
            .collect();
                let cache_key = get_project_analysis_cache_key(&project_root, &project_rs_files)?;
        
                match db.get(&cache_key) {
                    Ok(Some(cached_report_bytes)) => {
                        match serde_json::from_slice(&cached_report_bytes) {
                            Ok(cached_report) => {
                                extracted_data.merge_rust_report(project_root.display().to_string(), cached_report);
                                eprintln!("Cache HIT for Rust analysis of {}. Loaded from RocksDB.", project_root.display());
                            },
                            Err(e) => {
                                eprintln!("Cache DECODE ERROR for Rust analysis of {}: {}. Bytes: {:?}", project_root.display(), e, cached_report_bytes);
                                let report = run_analysis(&project_root, PRIMES_TO_ANALYZE);
                                let serialized_report = serde_json::to_vec(&report)?;
                                eprintln!("DEBUG: Serialized Rust AnalysisReport size: {}, first 100 bytes: {:?}", serialized_report.len(), &serialized_report[..std::cmp::min(serialized_report.len(), 100)]);
                                db.put(&cache_key, serialized_report)?;
                                extracted_data.merge_rust_report(project_root.display().to_string(), report);
                                eprintln!("Ran Rust analysis for {} and cached it.", project_root.display());
                            }
                        }
                    },
                    Ok(None) => {
                        eprintln!("Cache MISS for Rust analysis of {}. Running analysis.", project_root.display());
                        let report = run_analysis(&project_root, PRIMES_TO_ANALYZE);
                        let serialized_report = serde_json::to_vec(&report)?;
                        db.put(&cache_key, serialized_report)?;
                        extracted_data.merge_rust_report(project_root.display().to_string(), report);
                        eprintln!("Ran Rust analysis for {} and cached it.", project_root.display());
                    },
                    Err(e) => {
                        eprintln!("RocksDB READ ERROR for Rust analysis of {}: {}. Running analysis.", project_root.display(), e);
                        let report = run_analysis(&project_root, PRIMES_TO_ANALYZE);
                        let serialized_report = serde_json::to_vec(&report)?;
                        db.put(&cache_key, serialized_report)?;
                        extracted_data.merge_rust_report(project_root.display().to_string(), report);
                        eprintln!("Ran Rust analysis for {} and cached it.", project_root.display());
                    }
                }
    }
    // TODO: Process SVG files using `svg_files`
    eprintln!("\nProcessing SVG files...");
    for file_entry in svg_files {
        eprintln!("Processing SVG file: {}", file_entry.path.display());
        let cache_key = format!("svg_analysis_report:{}", calculate_file_content_hash(&file_entry.content));
        
        match db.get(&cache_key) {
            Ok(Some(cached_svg_extracted_data_bytes)) => {
                let cached_svg_extracted_data: ExtractedData = serde_json::from_slice(&cached_svg_extracted_data_bytes)?;
                // Merge terms and relationships from cached SVG data
                for (_name, term) in cached_svg_extracted_data.terms {
                    extracted_data.add_term(term);
                }
                for rel in cached_svg_extracted_data.relationships {
                    extracted_data.add_relationship(rel);
                }
                eprintln!("Cache HIT for SVG analysis of {}. Loaded from RocksDB.", file_entry.path.display());
            },
            Ok(None) => {
                eprintln!("Cache MISS for SVG analysis of {}. Running analysis.", file_entry.path.display());
                let mut svg_extracted_data = ExtractedData::new(); // Temporary ExtractedData for SVG processing
                process_svg_file(&file_entry, &mut svg_extracted_data)?;
                
                let serialized_svg_extracted_data = serde_json::to_vec(&svg_extracted_data)?;
                db.put(&cache_key, serialized_svg_extracted_data)?;

                // Merge terms and relationships from newly processed SVG data
                for (_name, term) in svg_extracted_data.terms {
                    extracted_data.add_term(term);
                }
                for rel in svg_extracted_data.relationships {
                    extracted_data.add_relationship(rel);
                }
                eprintln!("Ran SVG analysis for {} and cached it.", file_entry.path.display());
            },
            Err(e) => {
                eprintln!("RocksDB READ ERROR for SVG analysis of {}: {}. Running analysis.", file_entry.path.display(), e);
                let mut svg_extracted_data = ExtractedData::new(); // Temporary ExtractedData for SVG processing
                process_svg_file(&file_entry, &mut svg_extracted_data)?;
                
                let serialized_svg_extracted_data = serde_json::to_vec(&svg_extracted_data)?;
                db.put(&cache_key, serialized_svg_extracted_data)?;

                // Merge terms and relationships from newly processed SVG data
                for (_name, term) in svg_extracted_data.terms {
                    extracted_data.add_term(term);
                }
                for rel in svg_extracted_data.relationships {
                    extracted_data.add_relationship(rel);
                }
                eprintln!("Ran SVG analysis for {} and cached it.", file_entry.path.display());
            }
        }
    }
    Ok(())
}
