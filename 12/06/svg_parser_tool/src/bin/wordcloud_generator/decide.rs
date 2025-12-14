use std::path::PathBuf;
use svg_parser_tool::db_trait::CacheDB;
use svg_parser_tool::processors::{ExtractedData, FileEntry};
use svg_parser_tool::utils::calculate_master_cache_key;

pub fn decide(
    cache: &Box<dyn CacheDB>,
    root_path: &PathBuf,
    all_file_entries: &Vec<FileEntry>,
) -> Result<Option<ExtractedData>, Box<dyn std::error::Error>> {
    let master_cache_key = calculate_master_cache_key(root_path, all_file_entries);
    match cache.get(&master_cache_key)? {
        Some(cached_data_bytes) => {
            match serde_json::from_slice(&cached_data_bytes) {
                Ok(loaded_data) => {
                    eprintln!("Cache HIT for aggregated ExtractedData. Loaded from database.");
                    Ok(Some(loaded_data))
                },
                Err(e) => {
                    eprintln!("Cache DECODE ERROR for aggregated ExtractedData: {}. Re-processing all files. Bytes: {:?}", e, cached_data_bytes);
                    Ok(None)
                }
            }
        },
        None => {
            eprintln!("Cache MISS for aggregated ExtractedData. Processing all files.");
            Ok(None)
        }
    }
}
