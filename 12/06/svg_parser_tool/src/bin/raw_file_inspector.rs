use std::env;
use std::fs::{self, File};
use std::io::Write;
use std::path::PathBuf;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let args: Vec<String> = env::args().collect();

    if args.len() < 2 {
        eprintln!("Usage: {} <file_path> [output_raw_file_path] [num_bytes_to_read]", args[0]);
        return Ok(())
    }

    let file_path = PathBuf::from(&args[1]);
    let output_raw_file_path = args.get(2).map(PathBuf::from);
    let num_bytes_to_read: usize = args.get(3).and_then(|s| s.parse().ok()).unwrap_or(256);

    eprintln!("Inspecting file: {}", file_path.display());
    
    let content = fs::read(&file_path)?;
    let bytes_to_inspect = content.iter().take(num_bytes_to_read).copied().collect::<Vec<u8>>();

    // Print hex dump
    eprintln!("\n--- Hex Dump (first {} bytes) ---", bytes_to_inspect.len());
    for (i, byte) in bytes_to_inspect.iter().enumerate() {
        if i % 16 == 0 {
            eprint!("\n{:08x}: ", i);
        }
        eprint!("{:02x} ", byte);
    }
    eprintln!("\n--- End Hex Dump ---\n");

    // Save verbatim data if output path is provided
    if let Some(out_path) = output_raw_file_path {
        eprintln!("Saving verbatim data to: {}", out_path.display());
        let mut file = File::create(&out_path)?;
        file.write_all(&bytes_to_inspect)?;
        eprintln!("Verbatim data saved.");
    }

    Ok(())
}
