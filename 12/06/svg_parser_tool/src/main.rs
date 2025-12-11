use std::fs;
use std::io;
use config_lib;

fn main() -> io::Result<()> {
    let (config, _) = config_lib::find_and_read_config("lean_introspector/config.toml").map_err(|e| {
        eprintln!("Failed to read config file: {}", e);
        io::Error::new(io::ErrorKind::NotFound, e)
    })?;

    let input_path = &config.input_file;
    println!("Reading file: {}", input_path.display());
    let content = fs::read_to_string(input_path)?;

    println!("\nFile content:\n{}", content);

    Ok(())
}