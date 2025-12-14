use std::path::PathBuf;
use ignore::WalkBuilder;
use std::io::Read;
use std::fs;
use crate::db_trait::CacheDB;

use crate::processors::FileEntry; // Assuming FileEntry is defined in processors.rs

pub fn collect_all_file_entries(root_path: &PathBuf, db: &dyn CacheDB) -> Result<Vec<FileEntry>, Box<dyn std::error::Error>> {
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
