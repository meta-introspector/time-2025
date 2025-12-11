use std::fs;
use std::io::{self};
use config_lib;

// Declare the module containing the generated HIR
pub mod hir_model;

fn main() -> io::Result<()> {
    let (config, _) = config_lib::find_and_read_config("lean_introspector/config.toml").map_err(|e| {
        eprintln!("Failed to read config file: {}", e);
        io::Error::new(io::ErrorKind::NotFound, e)
    })?;

    let input_path = &config.input_file;
    println!("Reading and parsing file: {}", input_path.display());
    let content = fs::read_to_string(input_path)?;

    // This is the core transformation: deserializing the JSON string into the Rust HIR.
    let hir: hir_model::Expr = serde_json::from_str(&content)
        .map_err(|e| {
            eprintln!("Failed to deserialize JSON into HIR: {}", e);
            io::Error::new(io::ErrorKind::InvalidData, e)
        })?;

    println!("\nSuccessfully parsed JSON into HIR.");
    println!("--------------------------------------");
    
    // Print the debug representation of the parsed HIR struct.
    println!("{:#?}", hir);

    Ok(())
}