use std::fs;
use std::path::Path;
use rocksdb::{DB};
use pico_args::Arguments;
use serde_json::{self, Value};

// Define the RocksDB cache directory (same as in wordcloud_generator for consistency)
const ROCKSDB_CACHE_DIR: &str = "C:\\Users\\gentd\\.gemini\\tmp\\wordcloud_cache";

fn print_help() {
    println!(
        r#"cache_inspector
Usage: cache_inspector [OPTIONS]

Options:
  --list                            List all keys and their approximate sizes in the database.
  --get <KEY>                       Retrieve and print the value for a specific key.
  --delete <KEY>                    Delete a specific key-value pair.  --clear-all                       Clear the entire RocksDB database.
  --validate-json <KEY>             Retrieve a key's value and validate if it's valid JSON.
  --db-path <PATH>                  Specify an alternative RocksDB path (defaults to {}).
  -h, --help                        Print help information.
"#,
        ROCKSDB_CACHE_DIR
    );
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let mut args = Arguments::from_env();

    if args.contains(["-h", "--help"]) {
        print_help();
        return Ok(());
    }

    let db_path_str: String = args.opt_value_from_str("--db-path")?.unwrap_or(ROCKSDB_CACHE_DIR.to_string());
    let db_path = Path::new(&db_path_str);

    let db = DB::open_default(db_path)?;
    println!("RocksDB opened at: {}", db_path.display());

    if args.contains("--list") {
        println!("\n--- Listing all keys ---");
        for item in db.iterator(rocksdb::IteratorMode::Start) {
            let (key, value) = item?;
            println!("Key: {:?}, Size: {} bytes", String::from_utf8_lossy(&key), value.len());
        }
        println!("--- End of list ---");
    } else if let Some(key) = args.opt_value_from_str::<&str, String>("--get")? {
        println!("\n--- Getting value for key: {} ---", key);
        match db.get(&key)? {
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
        db.delete(&key)?;
        println!("Key deleted (if it existed).");
        println!("--- End of delete operation ---");
    } else if args.contains("--clear-all") {
        println!("\n--- Clearing entire database at: {} ---", db_path.display());
        // Close DB before deleting directory
        drop(db); 
        fs::remove_dir_all(db_path)?;
        println!("Database cleared.");
        println!("--- End of clear operation ---");
    } else if let Some(key) = args.opt_value_from_str::<&str, String>("--validate-json")? {
        println!("\n--- Validating JSON for key: {} ---", key);
        match db.get(&key)? {
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
