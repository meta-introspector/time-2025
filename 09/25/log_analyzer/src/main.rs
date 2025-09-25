
use clap::Parser;
use regex::Regex;
use serde_json::{Value, from_str};
use std::fs::File;
use std::io::{self, BufReader, BufRead};

#[derive(Parser, Debug)]
#[command(author, version, about, long_about = None)]
struct Args {
    /// Path to the telemetry log file
    #[arg(short, long)]
    log_file: String,
}

fn main() -> io::Result<()> {
    let args = Args::parse();

    let file = File::open(&args.log_file)?;
    let reader = BufReader::new(file);

    let error_keywords = Regex::new(r"(?i)error|fail|exception|denied|refused|timeout|panic").unwrap();

    println!("Analyzing log file: {}", args.log_file);
    println!("--- Errors ---");

    for line_result in reader.lines() {
        let line = line_result?;
        if let Ok(json_value) = from_str::<Value>(&line) {
            // Check for errors
            if let Some(body) = json_value.get("_body").and_then(|v| v.as_str()) {
                if error_keywords.is_match(body) {
                    println!("  [ERROR] Body: {}", body);
                }
            }
            if let Some(event_name) = json_value.get("attributes").and_then(|v| v.get("event.name")).and_then(|v| v.as_str()) {
                if error_keywords.is_match(event_name) {
                    println!("  [ERROR] Event Name: {}", event_name);
                }
            }
            if let Some(attributes) = json_value.get("attributes") {
                if let Some(function_name) = attributes.get("function_name").and_then(|v| v.as_str()) {
                    if let Some(success) = attributes.get("success").and_then(|v| v.as_bool()) {
                        if !success {
                            println!("  [ERROR] Tool call failed: {}", function_name);
                        }
                    }
                }
            }

            // Check for unfinished work (simple heuristic: tool calls without explicit success)
            if let Some(event_name) = json_value.get("attributes").and_then(|v| v.get("event.name")).and_then(|v| v.as_str()) {
                if event_name == "gemini_cli.tool_call" {
                    if let Some(attributes) = json_value.get("attributes") {
                        if attributes.get("success").is_none() {
                            if let Some(function_name) = attributes.get("function_name").and_then(|v| v.as_str()) {
                                println!("  [UNFINISHED WORK] Tool call without success status: {}", function_name);
                            }
                        }
                    }
                }
            }
        } else {
            // If it's not a JSON line, check for error keywords in plain text
            if error_keywords.is_match(&line) {
                println!("  [ERROR] Plain text line: {}", line);
            }
        }
    }

    println!("--- Analysis Complete ---");
    Ok(())
}
