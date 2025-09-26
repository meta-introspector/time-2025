
use clap::Parser;
use regex::Regex;
use serde_json::{Value, from_str};
use std::collections::HashMap;
use std::fs::File;
use std::io::{self, BufReader, BufRead};

#[derive(Parser, Debug)]
#[command(author, version, about, long_about = None)]
struct Args {
    /// Path to the telemetry log file
    #[arg(short, long)]
    log_file: String,
}

#[derive(Debug, Hash, PartialEq, Eq, Clone)]
enum LogError {
    GenericError,
    ContentRetryError(String),
    ContentRetryFailureEvent,
    ApiError(String),
    AbortError,
    InputTokenLimitExceeded { current: u64, max: u64 },
    PlainTextError(String),
    UnfinishedToolCall(String),
    FalsePositiveFailedStatus,
    ParsedApiError(ApiError),
    GenericErrorType(String),
    GenericStatusCode(String),
    ContentRetryDescription(String),
    ContentRetryFailureEventName(String),
    ContentRetryFailureDescription(String),
    AbortErrorType(String),
    GeminiCliApiEventName(String),
    GeminiCliApiError(GeminiCliApiErrorAttributes),
    NoResponseTextErrorType(String),
    ContentRetryFailedBody(String),
    FinalErrorTypeNoResponseText(String),
    GeminiCliChatContentRetryFailureEvent(String),
    EditExpectedOccurrenceMismatchErrorType(String),
    EditExpectedOccurrenceMismatchMessage(String),
}

// Represents a detailed error within the 'errors' array
#[derive(Debug, serde::Deserialize, serde::Serialize, Clone, PartialEq, Eq, Hash)]
pub struct ApiErrorDetail {
    pub message: String,
    pub domain: String,
    pub reason: String,
}

// Represents the main API error object
#[derive(Debug, serde::Deserialize, serde::Serialize, Clone, PartialEq, Eq, Hash)]
pub struct ApiError {
    pub code: u16,
    pub message: String,
    pub errors: Vec<ApiErrorDetail>,
    pub status: String,
}

// Represents the top-level structure if the error is embedded as a stringified JSON
// within a log entry, like in the "input token count exceeded" example.
#[derive(Debug, serde::Deserialize, serde::Serialize, Clone, PartialEq, Eq, Hash)]
pub struct LoggedErrorWrapper {
    pub error: ApiError,
}

#[derive(Debug, serde::Deserialize, serde::Serialize, Clone, PartialEq, Eq, Hash)]
pub struct GeminiCliApiErrorAttributes {
    pub message: Option<String>,
    pub details: Option<serde_json::Value>, // For any other unstructured details
}

// Event-specific attribute structs
#[derive(Debug, serde::Deserialize, serde::Serialize, Clone, PartialEq, Eq, Hash)]
pub struct ToolCallAttributes {
    pub success: Option<bool>,
    pub function_name: Option<String>,
    // Add other relevant attributes for tool calls if they exist
}

// Enum for known event names
#[derive(Debug, serde::Deserialize, serde::Serialize, Clone, PartialEq, Eq, Hash)]
#[serde(rename_all = "snake_case")] // Adjust if event names use a different casing
pub enum EventName {
    GeminiCliToolCall,
    GeminiCliChatContentRetryFailureCount,
    GeminiCliApiError,
    #[serde(other)]
    Unknown,
}

// Enum to hold different types of event attributes
#[derive(Debug, serde::Deserialize, serde::Serialize, Clone)]
#[serde(untagged)] // Attempt to deserialize into variants in order
pub enum EventAttributes {
    ToolCall(ToolCallAttributes),
    Generic(serde_json::Value), // Catch-all for events without specific attribute structs
}

// Struct to hold the parsed event and its attributes
#[derive(Debug, serde::Deserialize, serde::Serialize, Clone)]
pub struct Event {
    #[serde(rename = "event.name")]
    pub name: EventName,
    #[serde(flatten)] // Flatten the rest of the attributes into a map
    pub other_attributes: serde_json::Map<String, serde_json::Value>,
}

#[derive(Debug, Clone)]
struct LogEntry {
    timestamp: Option<String>,
    event: Option<Event>,
    all_fields: HashMap<String, Value>,
}

fn main() -> io::Result<()> {
    let args = Args::parse();

    let file = File::open(&args.log_file)?;
    let reader = BufReader::new(file);

    // Refined regex: removed 'fail' and added negative lookahead for 'failed: false'
    let error_keywords = Regex::new(r"(?i)error|exception|denied|refused|timeout|panic|fail").unwrap();
    let input_token_limit_regex = Regex::new(r"The input token count \((\d+)\) exceeds the maximum number of tokens allowed \((\d+)\).").unwrap();
    let api_error_json_regex = Regex::new(r#""error": "((?:[^"\\]|\\.)*)""#).unwrap();

    let mut error_counts: HashMap<LogError, usize> = HashMap::new();
    let mut all_log_entries: Vec<LogEntry> = Vec::new();
    let mut unclassified_errors: Vec<String> = Vec::new();

    println!("Analyzing log file: {}", args.log_file);

    for line_result in reader.lines() {
        let line = line_result?;
        if let Ok(json_value) = from_str::<Value>(&line) {
            let mut current_log_entry = LogEntry {
                timestamp: json_value.get("timestamp").and_then(|v| v.as_str()).map(|s| s.to_string()),
                event: {
                    if let Some(attributes_val) = json_value.get("attributes") {
                        let mut temp_event_json = serde_json::Map::new();
                        if let Some(event_name_val) = attributes_val.get("event.name") {
                            temp_event_json.insert("event.name".to_string(), event_name_val.clone());
                        }
                        if let Some(obj) = attributes_val.as_object() {
                            for (key, value) in obj {
                                if key != "event.name" { // Avoid duplicating event.name
                                    temp_event_json.insert(key.clone(), value.clone());
                                }
                            }
                        }
                        if !temp_event_json.is_empty() {
                            serde_json::from_value(serde_json::Value::Object(temp_event_json)).ok()
                        } else {
                            None
                        }
                    } else {
                        None
                    }
                },
                all_fields: { // Clone all fields into the HashMap
                    let mut map = HashMap::new();
                    if let Some(obj) = json_value.as_object() {
                        for (key, value) in obj {
                            map.insert(key.clone(), value.clone());
                        }
                    }
                    map
                },
            };
            all_log_entries.push(current_log_entry.clone()); // Use clone here

            let mut found_specific_error = false;

            // Check for specific error patterns in JSON
            if let Some(body) = json_value.get("_body").and_then(|v| v.as_str()) {
                if let Some(caps) = input_token_limit_regex.captures(body) {
                    if let (Ok(current), Ok(max)) = (caps[1].parse::<u64>(), caps[2].parse::<u64>()) {
                        *error_counts.entry(LogError::InputTokenLimitExceeded { current, max }).or_insert(0) += 1;
                        found_specific_error = true;
                    }
                }
                if body.contains("AbortError") {
                    *error_counts.entry(LogError::AbortError).or_insert(0) += 1;
                    found_specific_error = true;
                } else if body.contains("Counts retries due to content errors") {
                    *error_counts.entry(LogError::ContentRetryError(body.to_string())).or_insert(0) += 1;
                    found_specific_error = true;
                } else if body.contains("gemini_cli.api_error") {
                    *error_counts.entry(LogError::ApiError(body.to_string())).or_insert(0) += 1;
                    found_specific_error = true;
                } else if body.contains("\"error_type\": \"Error\"") {
                    *error_counts.entry(LogError::GenericError).or_insert(0) += 1;
                    found_specific_error = true;
                }
            }

            if let Some(event) = current_log_entry.event {
                match event.name {
                    EventName::GeminiCliChatContentRetryFailureCount => {
                        *error_counts.entry(LogError::ContentRetryFailureEvent).or_insert(0) += 1;
                        found_specific_error = true;
                    },
                    EventName::GeminiCliApiError => {
                        if let Ok(api_attrs) = serde_json::from_value::<GeminiCliApiErrorAttributes>(serde_json::Value::Object(event.other_attributes.clone())) {
                            *error_counts.entry(LogError::GeminiCliApiError(api_attrs)).or_insert(0) += 1;
                            found_specific_error = true;
                        } else {
                            *error_counts.entry(LogError::ApiError(format!("Failed to parse GeminiCliApiErrorAttributes: {:?}", event.other_attributes))).or_insert(0) += 1;
                            found_specific_error = true;
                        }
                    },
                    EventName::GeminiCliToolCall => {
                        if let Ok(attrs) = serde_json::from_value::<ToolCallAttributes>(serde_json::Value::Object(event.other_attributes.clone())) {
                            if let Some(success) = attrs.success {
                                if !success {
                                    *error_counts.entry(LogError::UnfinishedToolCall(format!("Tool call failed: {:?}", attrs.function_name))).or_insert(0) += 1;
                                    found_specific_error = true;
                                }
                            }
                        } else {
                            // If deserialization to ToolCallAttributes fails, treat as generic error
                            *error_counts.entry(LogError::ApiError(format!("Failed to parse ToolCallAttributes: {:?}", event.other_attributes))).or_insert(0) += 1;
                            found_specific_error = true;
                        }
                    },
                    _ => {} // Handle other event names if needed
                }
            }

            // Handle the "failed: false" false positive
            if line.contains("\"failed\": false") {
                *error_counts.entry(LogError::FalsePositiveFailedStatus).or_insert(0) += 1;
                found_specific_error = true;
            }

            // If it's a JSON line and contains error keywords but wasn't specifically classified
            if !found_specific_error && error_keywords.is_match(&line) {
                unclassified_errors.push(line.to_string());
            }

        } else { // Start of else block for non-JSON lines
            if line.contains("\"failed\": false") {
                *error_counts.entry(LogError::FalsePositiveFailedStatus).or_insert(0) += 1;
            } else if line.contains("\"error_type\": \"NO_RESPONSE_TEXT\",") {
                *error_counts.entry(LogError::NoResponseTextErrorType("NO_RESPONSE_TEXT".to_string())).or_insert(0) += 1;
            } else if line.contains("\"_body\": \"All content retries failed after 2 attempts.\",") {
                *error_counts.entry(LogError::ContentRetryFailedBody("All content retries failed after 2 attempts.".to_string())).or_insert(0) += 1;
            } else if line.contains("\"final_error_type\": \"NO_RESPONSE_TEXT\",") {
                *error_counts.entry(LogError::FinalErrorTypeNoResponseText("NO_RESPONSE_TEXT".to_string())).or_insert(0) += 1;
            } else if line.contains("\"event.name\": \"gemini_cli.chat.content_retry_failure\",") {
                *error_counts.entry(LogError::GeminiCliChatContentRetryFailureEvent("gemini_cli.chat.content_retry_failure".to_string())).or_insert(0) += 1;
            } else if line.contains("\"error_type\": \"Error\"") {
                *error_counts.entry(LogError::GenericErrorType("Error".to_string())).or_insert(0) += 1;
            } else if line.contains("\"status_code\": \"error\"") {
                *error_counts.entry(LogError::GenericStatusCode("error".to_string())).or_insert(0) += 1;
            } else if line.contains("\"description\": \"Counts retries due to content errors (e.g., empty stream).\",") {
                *error_counts.entry(LogError::ContentRetryDescription("Counts retries due to content errors (e.g., empty stream).".to_string())).or_insert(0) += 1;
            } else if line.contains("\"name\": \"gemini_cli.chat.content_retry_failure.count\",") {
                *error_counts.entry(LogError::ContentRetryFailureEventName("gemini_cli.chat.content_retry_failure.count".to_string())).or_insert(0) += 1;
            } else if line.contains("\"description\": \"Counts occurrences of all content retries failing.\",") {
                *error_counts.entry(LogError::ContentRetryFailureDescription("Counts occurrences of all content retries failing.".to_string())).or_insert(0) += 1;
            } else if line.contains("\"error_type\": \"AbortError\"") {
                *error_counts.entry(LogError::AbortErrorType("AbortError".to_string())).or_insert(0) += 1;
            } else if line.contains("\"event.name\": \"gemini_cli.api_error\",") {
                *error_counts.entry(LogError::GeminiCliApiEventName("gemini_cli.api_error".to_string())).or_insert(0) += 1;
            } else if line.contains("The input token count") {
                // Attempt to extract and parse the JSON part of the error by finding array delimiters
                if let Some(json_array_start_idx) = line.find("[") {
                    if let Some(json_array_end_idx) = line.rfind("]") {
                        if json_array_start_idx < json_array_end_idx {
                            let escaped_json_str = &line[json_array_start_idx ..= json_array_end_idx];

                            // Manually unescape the string
                            let unescaped_json_str = escaped_json_str
                                .replace("\\\"", "\"")
                                .replace("\\n", "\n")
                                .replace("\\t", "\t")
                                .replace("\\r", "\r")
                                .replace("\\\\", "\\"); // This should be last to avoid unescaping already unescaped backslashes

                            // The extracted JSON is an array of objects, so we need to parse it as Vec<LoggedErrorWrapper>
                            if let Ok(logged_error_wrappers) = serde_json::from_str::<Vec<LoggedErrorWrapper>>(&unescaped_json_str) {
                                for wrapper in logged_error_wrappers {
                                    *error_counts.entry(LogError::ParsedApiError(wrapper.error)).or_insert(0) += 1;
                                }
                            } else {
                                // If deserialization fails, fall back to PlainTextError
                                *error_counts.entry(LogError::PlainTextError(line.to_string())).or_insert(0) += 1;
                            }
                        } else {
                            // If array delimiters are not in order, fall back to PlainTextError
                            *error_counts.entry(LogError::PlainTextError(line.to_string())).or_insert(0) += 1;
                        }
                    } else {
                        // If end bracket not found, fall back to PlainTextError
                        *error_counts.entry(LogError::PlainTextError(line.to_string())).or_insert(0) += 1;
                    }
                } else { // This else corresponds to `if let Some(json_array_start_idx)`
                    // If start bracket not found, fall back to PlainTextError
                    *error_counts.entry(LogError::PlainTextError(line.to_string())).or_insert(0) += 1;
                }
            } else if error_keywords.is_match(&line) { // This is the final catch-all for error keywords
                *error_counts.entry(LogError::PlainTextError(line.to_string())).or_insert(0) += 1;
            }
        } // End of else block
    }

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
    Ok(())
}
