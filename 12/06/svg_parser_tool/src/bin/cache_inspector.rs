use std::fs;
use std::path::Path;
use rocksdb::{DB};
use pico_args::Arguments;
use serde_json::{self, Value};
use svg_parser_tool::db_trait::CacheDB;
use svg_parser_tool::rocksdb_cache::RocksDBCache;
use svg_parser_tool::redb_cache::RedbCache;
use svg_parser_tool::sled_cache::SledCache;
use redb::{ReadableDatabase, ReadableTable};

// Define the cache directories
const ROCKSDB_CACHE_DIR: &str = "C:\\Users\\gentd\\.gemini\\tmp\\wordcloud_cache_rocksdb";
const REDB_CACHE_DIR: &str = "C:\\Users\\gentd\\.gemini\\tmp\\wordcloud_cache_redb";
const SLED_CACHE_DIR: &str = "C:\\Users\\gentd\\.gemini\\tmp\\wordcloud_cache_sled";

fn print_help() {
    println!(
        r#"cache_inspector
Usage: cache_inspector [OPTIONS]

Options:
  --db-type <DB_TYPE>               The database type to use for caching. Can be 'rocksdb', 'redb', or 'sled'. Defaults to 'rocksdb'.
  --list                            List all keys and their approximate sizes in the database.
  --get <KEY>                       Retrieve and print the value for a specific key.
  --delete <KEY>                    Delete a specific key-value pair.  --clear-all                       Clear the entire RocksDB database.
  --validate-json <KEY>             Retrieve a key's value and validate if it's valid JSON.
  --db-path <PATH>                  Specify an alternative database path.
  -h, --help                        Print help information.
"#
    );
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let mut args = Arguments::from_env();

    if args.contains(["-h", "--help"]) {
        print_help();
        return Ok(());
    }

    let db_type: String = args.opt_value_from_str("--db-type")?.unwrap_or("rocksdb".to_string());

    let db_path_str: String = args.opt_value_from_str("--db-path")?.unwrap_or(
        match db_type.as_str() {
            "rocksdb" => ROCKSDB_CACHE_DIR.to_string(),
            "redb" => REDB_CACHE_DIR.to_string(),
            "sled" => SLED_CACHE_DIR.to_string(),
            _ => {
                eprintln!("Error: Invalid database type '{}'. Use 'rocksdb', 'redb', or 'sled'.", db_type);
                return Ok(());
            }
        }
    );
    let db_path = Path::new(&db_path_str);

    let cache: Box<dyn CacheDB> = match db_type.as_str() {
        "rocksdb" => {
            let db = DB::open_default(db_path)?;
            println!("RocksDB opened at: {}", db_path.display());
            let leaked_db = Box::leak(Box::new(db));
            Box::new(RocksDBCache::new(leaked_db))
        }
        "redb" => {
            let db = redb::Database::create(db_path)?;
            println!("Redb opened at: {}", db_path.display());
            let leaked_db = Box::leak(Box::new(db));
            Box::new(RedbCache::new(leaked_db)?)
        }
        "sled" => {
            let db = sled::open(db_path)?;
            println!("Sled opened at: {}", db_path.display());
            let leaked_db = Box::leak(Box::new(db));
            Box::new(SledCache::new(leaked_db))
        }
        _ => {
            eprintln!("Error: Invalid database type '{}'. Use 'rocksdb', 'redb', or 'sled'.", db_type);
            return Ok(());
        }
    };

    if args.contains("--list") {
        match db_type.as_str() {
            "rocksdb" => {
                let db = DB::open_default(db_path)?;
                println!("\n--- Listing all keys in RocksDB ---");
                for item in db.iterator(rocksdb::IteratorMode::Start) {
                    let (key, value) = item?;
                    println!("Key: {:?}, Size: {} bytes", String::from_utf8_lossy(&key), value.len());
                }
                println!("--- End of list ---");
            }
            "redb" => {
                println!("\n--- Listing all keys in Redb ---");
                let db = redb::Database::create(db_path)?;
                let read_txn = db.begin_read()?;
                let table = read_txn.open_table(svg_parser_tool::redb_cache::TABLE)?;
                for item in table.iter()? {
                    let (key, value) = item?;
                    println!("Key: {:?}, Size: {} bytes", key.value(), value.value().len());
                }
                println!("--- End of list ---");
            }
            "sled" => {
                println!("\n--- Listing all keys in Sled ---");
                let db = sled::open(db_path)?;
                for item in db.iter() {
                    let (key, value) = item?;
                    println!("Key: {:?}, Size: {} bytes", String::from_utf8_lossy(&key), value.len());
                }
                println!("--- End of list ---");
            }
            _ => {}
        }
    } else if let Some(key) = args.opt_value_from_str::<&str, String>("--get")? {
        println!("\n--- Getting value for key: {} ---", key);
        match cache.get(&key)? {
            Some(value) => {
                println!("Value found. Size: {} bytes", value.len());
                let s = String::from_utf8_lossy(&value);
                // Attempt to pretty-print as JSON
                match serde_json::from_str::<Value>(&s) {
                    Ok(json_value) => {
                        println!("Pretty-printed JSON:\n{}", serde_json::to_string_pretty(&json_value)?);
                    },
                    Err(_) => {
                        println!("Content (not valid JSON, or could not be parsed as JSON):\n{}", s);
                    }
                }
            },
            None => {
                println!("Key not found.");
            }
        }
        println!("--- End of get operation ---");
    } else if let Some(key) = args.opt_value_from_str::<&str, String>("--delete")? {
        println!("\n--- Deleting key: {} ---", key);
        // db.delete(&key)?;
        println!("Delete not yet implemented for the abstract cache.");
        println!("--- End of delete operation ---");
    } else if args.contains("--clear-all") {
        println!("\n--- Clearing entire database at: {} ---", db_path.display());
        // drop(db); 
        fs::remove_dir_all(db_path)?;
        println!("Database cleared.");
        println!("--- End of clear operation ---");
    } else if let Some(key) = args.opt_value_from_str::<&str, String>("--validate-json")? {
        println!("\n--- Validating JSON for key: {} ---", key);
        match cache.get(&key)? {
            Some(value) => {
                let s = String::from_utf8_lossy(&value);
                match serde_json::from_str::<Value>(&s) {
                    Ok(_) => {
                        println!("Value for key '{}' is valid JSON.", key);
                    },
                    Err(e) => {
                        println!("Value for key '{}' is NOT valid JSON. Error: {}", key, e);
                        println!("Content:\n{}", s);
                    }
                }
            },
            None => {
                println!("Key not found.");
            }
        }
        println!("--- End of validate JSON operation ---");
    } else {
        print_help();
    }

    Ok(())
}
