use std::path::PathBuf;
use svg_parser_tool::db_trait::CacheDB;
use svg_parser_tool::processors::{ExtractedData, FileEntry};
use svg_parser_tool::rust_processor::process_rust_files;
use svg_parser_tool::svg_processor::process_svg_files;

pub fn act(
    db: &dyn CacheDB,
    all_file_entries: &[FileEntry],
    extracted_data: &mut ExtractedData,
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

    Ok(())
}
