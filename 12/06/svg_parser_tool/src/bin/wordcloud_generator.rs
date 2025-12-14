use std::path::{Path, PathBuf};
use rocksdb::{DB};
use serde_json;
use pico_args::Arguments;

use svg_parser_tool::processors::{ExtractedData, FileEntry, PRIMES_TO_ANALYZE};
use svg_parser_tool::utils::{calculate_master_cache_key};
use svg_parser_tool::file_collector::collect_all_file_entries;
use svg_parser_tool::rust_processor::process_rust_files;
use svg_parser_tool::svg_processor::process_svg_files;
use svg_parser_tool::rocksdb_cache::RocksDBCache;
use svg_parser_tool::redb_cache::RedbCache;
use svg_parser_tool::db_trait::CacheDB;

// Define the cache directories
const ROCKSDB_CACHE_DIR: &str = "C:\\Users\\gentd\\.gemini\\tmp\\wordcloud_cache_rocksdb";
const REDB_CACHE_DIR: &str = "C:\\Users\\gentd\\.gemini\\tmp\\wordcloud_cache_redb";

fn print_help() {
    println!(
        r#"wordcloud_generator
Usage: wordcloud_generator [PATH] [OPTIONS]

Arguments:
  [PATH]    The root directory to start collecting files from. Defaults to current directory.

Options:
  --db-type <DB_TYPE>    The database type to use for caching. Can be 'rocksdb' or 'redb'. Defaults to 'rocksdb'.
  -h, --help             Print help information
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

    let db_type: String = args.opt_value_from_str("--db-type")?.unwrap_or("rocksdb".to_string());

    let root_path_str: String = args.free_from_str().unwrap_or_else(|_| ".".to_string());
    let root_path = PathBuf::from(root_path_str);

    let cache: Box<dyn CacheDB> = match db_type.as_str() {
        "rocksdb" => {
            let db = DB::open_default(ROCKSDB_CACHE_DIR)?;
            println!("RocksDB opened at: {}", ROCKSDB_CACHE_DIR);
            let leaked_db = Box::leak(Box::new(db));
            Box::new(RocksDBCache::new(leaked_db))
        }
        "redb" => {
            let db = redb::Database::create(REDB_CACHE_DIR)?;
            println!("Redb opened at: {}", REDB_CACHE_DIR);
            let leaked_db = Box::leak(Box::new(db));
            Box::new(RedbCache::new(leaked_db))
        }
        _ => {
            eprintln!("Error: Invalid database type '{}'. Use 'rocksdb' or 'redb'.", db_type);
            return Ok(());
        }
    };

    let mut extracted_data: ExtractedData;

    let all_file_entries = collect_all_file_entries(&root_path, cache.as_ref())?;

    let master_cache_key = calculate_master_cache_key(&root_path, &all_file_entries);

    // Attempt to load aggregated ExtractedData from cache
    match cache.get(&master_cache_key)? {
        Some(cached_data_bytes) => {
            match serde_json::from_slice(&cached_data_bytes) {
                Ok(loaded_data) => {
                    extracted_data = loaded_data;
                    eprintln!("Cache HIT for aggregated ExtractedData. Loaded from database.");
                },
                Err(e) => {
                    eprintln!("Cache DECODE ERROR for aggregated ExtractedData: {}. Re-processing all files. Bytes: {:?}", e, cached_data_bytes);
                    extracted_data = ExtractedData::new(); // Reset and re-process
                    process_files_and_cache(&root_path, cache.as_ref(), &all_file_entries, &mut extracted_data, master_cache_key.as_bytes())?;
                    eprintln!("Re-processed all files and cached aggregated ExtractedData.");
                }
            }
        },
        None => {
            eprintln!("Cache MISS for aggregated ExtractedData. Processing all files.");
            extracted_data = ExtractedData::new();
            process_files_and_cache(&root_path, cache.as_ref(), &all_file_entries, &mut extracted_data, master_cache_key.as_bytes())?;
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


use svg_parser_tool::db_trait::CacheDB;
fn process_files_and_cache(
    root_path: &PathBuf,
    db: &dyn CacheDB,
    all_file_entries: &[FileEntry],
    extracted_data: &mut ExtractedData,
    master_cache_key: &[u8],
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
    process_rust_files(db, &rs_files, &cargo_toml_files, extracted_data)?;

    // Process SVG files
    process_svg_files(db, &svg_files, extracted_data)?;

    // Serialize and cache the aggregated ExtractedData
    let serialized_extracted_data = serde_json::to_vec(extracted_data)?;
    db.put(&String::from_utf8_lossy(master_cache_key), &serialized_extracted_data)?;

    Ok(())
}