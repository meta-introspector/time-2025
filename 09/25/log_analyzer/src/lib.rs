
use clap::Parser;
use std::io::{self};
use std::collections::HashMap;
use serde_json::{Value};
use std::time::Instant;

pub mod layers;
pub mod models;
pub mod debug;
pub mod error_analysis;
pub mod session_analysis;
pub mod url_extractor;

pub use url_extractor::extract_urls;

use crate::layers::ingestion::RawDataIngestionLayer;
use crate::layers::segmentation::JsonExtractorLayer;
use crate::layers::parsing::JsonParsingLayer;
use crate::models::{LogEntry, ExprObject};
use crate::error_analysis::{LogError, analyze_errors};
use crate::session_analysis::reconstruct_and_print_sessions;
use crate::debug::StepTracer;

#[derive(Parser, Debug)]
#[command(author, version, about, long_about = None)]
pub struct Args {
    /// Path to the telemetry log file
    #[arg(short, long)]
    pub log_file: String,

    /// Process only the first N blocks
    #[arg(long)]
    pub head: Option<usize>,

    /// Stop after N steps
    #[arg(long)]
    pub max_steps: Option<usize>,
}

pub fn run() -> io::Result<()> {
    let args = Args::parse();

    let tracer = std::sync::Arc::new(StepTracer::new(args.max_steps));

    let file = std::fs::File::open(&args.log_file)?;
    let mut ingestion_layer = RawDataIngestionLayer::new(file, tracer.clone())?;
    let mut buffer_management_layer = crate::layers::buffer_management::BufferManagementLayer::new();
    let mut boundary_detector = crate::layers::json_boundary_detector::JsonBoundaryDetector::new();
    let mut json_extractor_layer = JsonExtractorLayer::new(tracer.clone());
    let parsing_layer = JsonParsingLayer::new(tracer.clone());

    let mut all_log_entries: Vec<LogEntry> = Vec::new();

    println!("Starting log file processing...");

    let start_ingestion_segmentation = Instant::now();
    let mut raw_json_strings: Vec<String> = Vec::new();

    loop {
        match ingestion_layer.read_chunk()? {
            Some(chunk) => {
                buffer_management_layer.extend_buffer(chunk);
                let current_buffered_data = buffer_management_layer.get_buffered_data();
                let boundaries = boundary_detector.detect_boundaries(current_buffered_data);
                let json_objects = json_extractor_layer.extract_json_objects(current_buffered_data, &boundaries);
                raw_json_strings.extend(json_objects);
                // Consume data up to the end of the last detected boundary
                if let Some((_start, end)) = boundaries.last() {
                    buffer_management_layer.consume_data(*end);
                }
            },
            None => {
                // Process any remaining data in the buffer after EOF
                let current_buffered_data = buffer_management_layer.get_buffered_data();
                let boundaries = boundary_detector.detect_boundaries(current_buffered_data);
                let json_objects = json_extractor_layer.extract_json_objects(current_buffered_data, &boundaries);
                raw_json_strings.extend(json_objects);
                break;
            },
        }
    }
    let duration_ingestion_segmentation = start_ingestion_segmentation.elapsed();
    println!("Finished reading and segmenting log file. Found {} JSON objects. Took: {:?}", raw_json_strings.len(), duration_ingestion_segmentation);

    println!("Starting JSON parsing and log entry creation...");
    let start_parsing_log_entry = Instant::now();
    let mut count = 0;
    let json_strings_to_process = if let Some(head) = args.head {
        raw_json_strings.into_iter().take(head).collect::<Vec<_>>()
    } else {
        raw_json_strings
    };

    for json_string in json_strings_to_process {
        // Temporarily disable granular tracer steps in this loop for cleaner timing
        // tracer.step("Processing a JSON string");
        // tracer.step(&format!("Parsing JSON string (length: {})", json_string.len()));
        if let Some(expr_object) = parsing_layer.parse_json(&json_string) {
            // tracer.step("Creating LogEntry");
            let current_log_entry = LogEntry {
                timestamp: if let ExprObject::Object(ref obj) = expr_object {
                    obj.get("timestamp").and_then(|v| if let ExprObject::Scalar(Value::String(s)) = v { Some(s.to_string()) } else { None })
                } else { None },
                event: {
                    if let ExprObject::Object(ref obj) = expr_object {
                        if let Some(attributes_val) = obj.get("attributes") {
                            if let ExprObject::Object(ref attrs_obj) = attributes_val {
                                let mut temp_event_json = serde_json::Map::new();
                                if let Some(event_name_val) = attrs_obj.get("event.name") {
                                    if let ExprObject::Scalar(Value::String(s)) = event_name_val {
                                        temp_event_json.insert("event.name".to_string(), Value::String(s.clone()));
                                    }
                                }
                                for (key, value) in attrs_obj {
                                    if key != "event.name" { // Avoid duplicating event.name
                                        if let ExprObject::Scalar(val) = value {
                                            temp_event_json.insert(key.clone(), val.clone());
                                        }
                                    }
                                }
                                if !temp_event_json.is_empty() {
                                    serde_json::from_value(serde_json::Value::Object(temp_event_json)).ok()
                                } else {
                                    None
                                }
                            } else { None }
                        } else { None }
                    } else { None }
                },
                all_fields: expr_object,
            };
            // tracer.step("Pushing LogEntry");
            all_log_entries.push(current_log_entry);
            tracer.step(&format!("Processed log entry {}", count));
            count += 1;
            if count % 10000 == 0 {
                println!("  ... processed {} log entries", count);
            }
        }
    }
    let duration_parsing_log_entry = start_parsing_log_entry.elapsed();
    println!("Finished JSON parsing and log entry creation. Took: {:?}", duration_parsing_log_entry);

    println!("Starting error analysis...");
    let start_error_analysis = Instant::now();
    let (error_counts, unclassified_errors) = analyze_errors(&all_log_entries, tracer.clone());
    let duration_error_analysis = start_error_analysis.elapsed();
    println!("Finished error analysis. Took: {:?}", duration_error_analysis);

    println!("--- Top 10 Errors ---");
    let mut sorted_errors: Vec<(&LogError, &usize)> = error_counts.iter().collect();
    sorted_errors.sort_by(|a, b| b.1.cmp(a.1));

    for (error_msg, count) in sorted_errors.iter().take(10) {
        println!("  Count: {}, Error: {:?}", count, error_msg);
    }

    println!("\n--- Suggestions for New Error Classes and Regexes ---");
    if unclassified_errors.is_empty() {
        println!("No unclassified errors found to suggest new classes.");
    } else {
        let mut filtered_unclassified_errors: Vec<String> = Vec::new();
        let noise_keywords = ["rust program", "nix flakes", "document what", "crq.txt"];

        for error_line in unclassified_errors {
            // Filter out very long lines or lines containing noise keywords
            if error_line.len() < 200 && !noise_keywords.iter().any(|&keyword| error_line.contains(keyword)) {
                filtered_unclassified_errors.push(error_line);
            }
        }

        if filtered_unclassified_errors.is_empty() {
            println!("No meaningful unclassified errors found after filtering.");
        } else {
            println!("Analyzing {} filtered unclassified error lines for new patterns...", filtered_unclassified_errors.len());
            let mut phrase_counts: HashMap<String, usize> = HashMap::new();
            for error_line in &filtered_unclassified_errors {
                // Simple phrase extraction (e.g., 2-word phrases)
                let words: Vec<&str> = error_line.split_whitespace().collect();
                for i in 0..words.len() {
                    if i + 1 < words.len() {
                        let phrase = format!("{} {}", words[i], words[i+1]);
                        *phrase_counts.entry(phrase).or_insert(0) += 1;
                    }
                }
            }

            let mut sorted_phrases: Vec<(&String, &usize)> = phrase_counts.iter().collect();
            sorted_phrases.sort_by(|a, b| b.1.cmp(a.1));

            println!("Top 5 suggested new error patterns:");
            for (phrase, count) in sorted_phrases.iter().take(5) {
                println!("  - Phrase: \"{}\", Occurrences: {}", phrase, count);
                println!("    Suggested Regex: `r\"(?i){}\"`", regex::escape(phrase));
                println!("    Suggested LogError variant: `NewErrorClass(String)` or `NewErrorClass {{ field: String }}`");
            }
        }
    }

    println!("\n--- Data Structure for All Log Data ---");
    println!("All log entries are parsed into a `Vec<LogEntry>`.");
    println!("Each `LogEntry` struct contains common fields like `timestamp` and `event_name`.");
    println!("All other fields from the original JSON are stored in an `all_fields: HashMap<String, serde_json::Value>` within each `LogEntry`.");
    println!("This allows for structured access to common fields and flexible access to all other data.");
    println!("Total log entries processed: {}", all_log_entries.len());

    println!("\n--- Analysis Complete ---");

    println!("Starting session reconstruction...");
    let start_session_reconstruction = Instant::now();
    reconstruct_and_print_sessions(&all_log_entries, tracer.clone());
    let duration_session_reconstruction = start_session_reconstruction.elapsed();
    println!("Finished session reconstruction. Took: {:?}", duration_session_reconstruction);

    Ok(())
}
