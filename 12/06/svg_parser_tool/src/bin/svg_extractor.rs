use std::env;
use std::fs;
use std::path::PathBuf;
use serde_json;
use std::io::Write; 
use std::panic;
use std::sync::Mutex;

use svg_parser_tool::processors::{ExtractedData, FileEntry, process_svg_file};

// Global static Mutex for the log file to allow the panic hook to access it
static LOG_FILE_MUTEX: Mutex<Option<fs::File>> = Mutex::new(None);

fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Initialize the custom panic hook first
    let log_path = PathBuf::from("output/svg_extractor_error.log");
    let initial_log_file = std::fs::OpenOptions::new()
        .create(true)
        .append(true)
        .open(&log_path)?;

    *LOG_FILE_MUTEX.lock().unwrap() = Some(initial_log_file);

    panic::set_hook(Box::new(|panic_info| {
        if let Some(mut log_file) = LOG_FILE_MUTEX.lock().unwrap().as_mut() {
            let _ = writeln!(log_file, "PANIC: {}", panic_info);
            let _ = log_file.flush();
        }
        // Call the default hook as well, so the panic still behaves normally
        // (e.g., prints to stderr if not redirected elsewhere)
        let _ = writeln!(std::io::stderr(), "PANIC: {}", panic_info);
    }));

    let args: Vec<String> = env::args().collect();

    // Re-open the log file for normal use, now that the panic hook is set up
    let mut log_file = std::fs::OpenOptions::new()
        .create(true)
        .append(true)
        .open("output/svg_extractor_error.log")?;

    if args.len() < 3 {
        let _ = writeln!(log_file, "Usage: {} <input_svg_path> <output_json_path>", args[0]);
        return Ok(());
    }

    let input_svg_path = PathBuf::from(&args[1]);
    let output_json_path = PathBuf::from(&args[2]);

    let _ = writeln!(log_file, "Processing SVG file: {}", input_svg_path.display());
    
    let content = fs::read(&input_svg_path)?;
    let file_entry = FileEntry { path: input_svg_path.clone(), content };

    let mut extracted_data = ExtractedData::new();
    match process_svg_file(&file_entry, &mut extracted_data) {
        Ok(_) => {
            let _ = writeln!(log_file, "Serializing ExtractedData to JSON and writing to: {}", output_json_path.display());
            let serialized_data = serde_json::to_string_pretty(&extracted_data)?;
            fs::write(&output_json_path, serialized_data)?;
            let _ = writeln!(log_file, "Successfully extracted and saved data.");
        },
        Err(e) => {
            let _ = writeln!(log_file, "Error processing SVG file: {}", e);
            return Err(e);
        }
    }


    Ok(())
}
