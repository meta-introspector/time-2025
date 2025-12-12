use rocksdb::DB;
use serde_json;

use monster_svg_morphism::analyzer::run_analysis;
use crate::processors::{ExtractedData, FileEntry, PRIMES_TO_ANALYZE};
use crate::utils::get_project_analysis_cache_key;

pub fn process_rust_files(
    db: &DB,
    rs_files: &[&FileEntry],
    cargo_toml_files: &[&FileEntry],
    extracted_data: &mut ExtractedData,
) -> Result<(), Box<dyn std::error::Error>> {
    let project_roots = crate::utils::identify_project_roots(cargo_toml_files.iter().map(|fe| fe.path.clone()).collect());

    for project_root in &project_roots {
        eprintln!("Running analysis for Rust project: {}", project_root.display());
        
        let project_rs_files: Vec<&FileEntry> = rs_files.iter()
            .filter(|fe| fe.path.starts_with(project_root))
            .cloned()
            .collect();
        let _cache_key = get_project_analysis_cache_key(project_root, &project_rs_files)?;
        
        match db.get(&_cache_key) {
            Ok(Some(cached_report_bytes)) => {
                match serde_json::from_slice(&cached_report_bytes) {
                    Ok(cached_report) => {
                        extracted_data.merge_rust_report(project_root.display().to_string(), cached_report);
                        eprintln!("Cache HIT for Rust analysis of {}. Loaded from RocksDB.", project_root.display());
                    },
                    Err(e) => {
                        eprintln!("Cache DECODE ERROR for Rust analysis of {}: {}. Bytes: {:?}. Re-running analysis.", project_root.display(), e, cached_report_bytes);
                        let report = run_analysis(project_root, PRIMES_TO_ANALYZE);
                        match serde_json::to_vec(&report) {
                            Ok(serialized_report) => {
                                eprintln!("DEBUG: Serialized Rust AnalysisReport size: {}, first 100 bytes: {:?}", serialized_report.len(), &serialized_report[..std::cmp::min(serialized_report.len(), 100)]);
                                db.put(&_cache_key, serialized_report)?;
                                extracted_data.merge_rust_report(project_root.display().to_string(), report);
                                eprintln!("Ran Rust analysis for {} and cached it.", project_root.display());
                            },
                            Err(ser_err) => {
                                eprintln!("CRITICAL ERROR: Failed to serialize AnalysisReport for {} after cache decode error: {}", project_root.display(), ser_err);
                                extracted_data.merge_rust_report(project_root.display().to_string(), report);
                            }
                        }
                    }
                }
            },
            Ok(None) => {
                eprintln!("Cache MISS for Rust analysis of {}. Running analysis.", project_root.display());
                let report = run_analysis(project_root, PRIMES_TO_ANALYZE);
                match serde_json::to_vec(&report) {
                    Ok(serialized_report) => {
                        eprintln!("DEBUG: Serialized Rust AnalysisReport size: {}, first 100 bytes: {:?}", serialized_report.len(), &serialized_report[..std::cmp::min(serialized_report.len(), 100)]);
                        db.put(&_cache_key, serialized_report)?;
                        extracted_data.merge_rust_report(project_root.display().to_string(), report);
                        eprintln!("Ran Rust analysis for {} and cached it.", project_root.display());
                    },
                    Err(ser_err) => {
                        eprintln!("CRITICAL ERROR: Failed to serialize AnalysisReport for {}: {}", project_root.display(), ser_err);
                        extracted_data.merge_rust_report(project_root.display().to_string(), report);
                    }
                }
            },
            Err(e) => {
                eprintln!("RocksDB READ ERROR for Rust analysis of {}: {}. Running analysis.", project_root.display(), e);
                let report = run_analysis(project_root, PRIMES_TO_ANALYZE);
                match serde_json::to_vec(&report) {
                    Ok(serialized_report) => {
                        eprintln!("DEBUG: Serialized Rust AnalysisReport size: {}, first 100 bytes: {:?}", serialized_report.len(), &serialized_report[..std::cmp::min(serialized_report.len(), 100)]);
                        db.put(&_cache_key, serialized_report)?;
                        extracted_data.merge_rust_report(project_root.display().to_string(), report);
                        eprintln!("Ran Rust analysis for {} and cached it.", project_root.display());
                    },
                    Err(ser_err) => {
                        eprintln!("CRITICAL ERROR: Failed to serialize AnalysisReport for {} after RocksDB read error: {}", project_root.display(), ser_err);
                        extracted_data.merge_rust_report(project_root.display().to_string(), report);
                    }
                }
            }
        }
    }
    Ok(())
}
