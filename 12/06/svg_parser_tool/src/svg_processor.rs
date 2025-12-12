use rocksdb::DB;
use serde_json;

use crate::processors::{ExtractedData, FileEntry, process_svg_file};
use crate::utils::calculate_file_content_hash;

pub fn process_svg_files(
    db: &DB,
    svg_files: &[&FileEntry],
    extracted_data: &mut ExtractedData,
) -> Result<(), Box<dyn std::error::Error>> {
    eprintln!("\nProcessing SVG files...");
    for file_entry in svg_files {
        eprintln!("Processing SVG file: {}", file_entry.path.display());
        let cache_key = format!("svg_analysis_report:{}", calculate_file_content_hash(&file_entry.content));
        
        match db.get(&cache_key) {
            Ok(Some(cached_svg_extracted_data_bytes)) => {
                match serde_json::from_slice::<ExtractedData>(&cached_svg_extracted_data_bytes) { // Explicit type annotation added here
                    Ok(cached_svg_extracted_data) => {
                        // Merge terms and relationships from cached SVG data
                        for (_name, term) in cached_svg_extracted_data.terms {
                            extracted_data.add_term(term);
                        }
                        for rel in cached_svg_extracted_data.relationships {
                            extracted_data.add_relationship(rel);
                        }
                        eprintln!("Cache HIT for SVG analysis of {}. Loaded from RocksDB.", file_entry.path.display());
                    },
                    Err(e) => {
                        eprintln!("Cache DECODE ERROR for SVG analysis of {}: {}. Bytes: {:?}. Re-running analysis.", file_entry.path.display(), e, cached_svg_extracted_data_bytes);
                        let mut svg_extracted_data = ExtractedData::new(); // Temporary ExtractedData for SVG processing
                        process_svg_file(&file_entry, &mut svg_extracted_data)?;
                        
                        match serde_json::to_vec(&svg_extracted_data) {
                            Ok(serialized_svg_extracted_data) => {
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
                            Err(ser_err) => {
                                eprintln!("CRITICAL ERROR: Failed to serialize SVG ExtractedData for {} after cache decode error: {}", file_entry.path.display(), ser_err);
                                // Still merge the data to continue processing, but don't cache invalid data
                                for (_name, term) in svg_extracted_data.terms {
                                    extracted_data.add_term(term);
                                }
                                for rel in svg_extracted_data.relationships {
                                    extracted_data.add_relationship(rel);
                                }
                            }
                        }
                    }
                }
            },
            Ok(None) => {
                eprintln!("Cache MISS for SVG analysis of {}. Running analysis.", file_entry.path.display());
                let mut svg_extracted_data = ExtractedData::new(); // Temporary ExtractedData for SVG processing
                process_svg_file(&file_entry, &mut svg_extracted_data)?;
                
                match serde_json::to_vec(&svg_extracted_data) {
                    Ok(serialized_svg_extracted_data) => {
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
                    Err(ser_err) => {
                        eprintln!("CRITICAL ERROR: Failed to serialize SVG ExtractedData for {}: {}", file_entry.path.display(), ser_err);
                        // Still merge the data to continue processing, but don't cache invalid data
                        for (_name, term) in svg_extracted_data.terms {
                            extracted_data.add_term(term);
                        }
                        for rel in svg_extracted_data.relationships {
                            extracted_data.add_relationship(rel);
                        }
                    }
                }
            },
            Err(e) => {
                eprintln!("RocksDB READ ERROR for SVG analysis of {}: {}. Running analysis.", file_entry.path.display(), e);
                let mut svg_extracted_data = ExtractedData::new(); // Temporary ExtractedData for SVG processing
                process_svg_file(&file_entry, &mut svg_extracted_data)?;
                
                match serde_json::to_vec(&svg_extracted_data) {
                    Ok(serialized_svg_extracted_data) => {
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
                    Err(ser_err) => {
                        eprintln!("CRITICAL ERROR: Failed to serialize SVG ExtractedData for {} after RocksDB read error: {}", file_entry.path.display(), ser_err);
                        // Still merge the data to continue processing, but don't cache invalid data
                        for (_name, term) in svg_extracted_data.terms {
                            extracted_data.add_term(term);
                        }
                        for rel in svg_extracted_data.relationships {
                            extracted_data.add_relationship(rel);
                        }
                    }
                }
            }
        }
    }
    Ok(())
}