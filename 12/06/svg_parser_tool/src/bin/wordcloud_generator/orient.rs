use std::path::{Path, PathBuf};
use rocksdb::DB;
use svg_parser_tool::db_trait::CacheDB;
use svg_parser_tool::rocksdb_cache::RocksDBCache;
use svg_parser_tool::redb_cache::RedbCache;
use svg_parser_tool::sled_cache::SledCache;
use svg_parser_tool::file_collector::collect_all_file_entries;
use svg_parser_tool::processors::FileEntry;

// Define the cache directories
const ROCKSDB_CACHE_DIR: &str = "C:\\Users\\gentd\\.gemini\\tmp\\wordcloud_cache_rocksdb";
const REDB_CACHE_DIR: &str = "C:\\Users\\gentd\\.gemini\\tmp\\wordcloud_cache_redb";
const SLED_CACHE_DIR: &str = "C:\\Users\\gentd\\.gemini\\tmp\\wordcloud_cache_sled";

pub fn orient(root_path: &PathBuf, db_type: &str) -> Result<(Box<dyn CacheDB>, Vec<FileEntry>), Box<dyn std::error::Error>> {
    let cache: Box<dyn CacheDB> = match db_type {
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
            Box::new(RedbCache::new(leaked_db)?)
        }
        "sled" => {
            let db = sled::open(SLED_CACHE_DIR)?;
            println!("Sled opened at: {}", SLED_CACHE_DIR);
            let leaked_db = Box::leak(Box::new(db));
            Box::new(SledCache::new(leaked_db))
        }
        _ => {
            eprintln!("Error: Invalid database type '{}'. Use 'rocksdb', 'redb', or 'sled'.", db_type);
            std::process::exit(1);
        }
    };

    let all_file_entries = collect_all_file_entries(root_path, cache.as_ref())?;
    Ok((cache, all_file_entries))
}
