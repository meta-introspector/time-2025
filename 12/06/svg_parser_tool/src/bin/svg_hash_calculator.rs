use std::env;
use std::fs;
use sha2::{Sha256, Digest};
use std::path::PathBuf;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let args: Vec<String> = env::args().collect();

    if args.len() < 2 {
        eprintln!("Usage: {} <file_path>", args[0]);
        return Ok(());
    }

    let file_path_str = &args[1];
    let file_path = PathBuf::from(file_path_str);

    let content = fs::read(&file_path)?; // Read content as bytes

    let mut hasher = Sha256::new();
    hasher.update(&content);
    let hash = hasher.finalize();

    println!("{:x}", hash); // Print hash as hexadecimal string

    Ok(())
}
