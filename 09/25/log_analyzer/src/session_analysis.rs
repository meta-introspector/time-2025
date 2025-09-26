use std::collections::HashMap;
use crate::models::{LogEntry, EventName, ToolCallAttributes, ExprObject};

pub fn reconstruct_and_print_sessions(log_entries: &[LogEntry], tracer: std::sync::Arc<crate::debug::StepTracer>) {
    println!("\n--- Session Reconstruction ---");

    let mut sessions: HashMap<String, Vec<LogEntry>> = HashMap::new();
    for entry in log_entries {
        tracer.step("Reconstructing a session");
        if let ExprObject::Object(ref obj) = entry.all_fields {
            if let Some(session_id_expr) = obj.get("session_id") {
                if let ExprObject::Scalar(serde_json::Value::String(session_id)) = session_id_expr {
                    sessions.entry(session_id.to_string()).or_default().push(entry.clone());
                }
            }
        }
    }

    println!("Found {} sessions.", sessions.len());

    for (session_id, entries) in sessions {
        println!("\n--- Session: {} ---", session_id);
        for entry in entries {
            if let Some(event) = &entry.event {
                if let EventName::GeminiCliToolCall = event.name {
                    if let Ok(attrs) = serde_json::from_value::<ToolCallAttributes>(serde_json::Value::Object(event.other_attributes.clone())) {
                        let success_str = if attrs.success.unwrap_or(false) { "SUCCESS" } else { "FAILURE" };
                        let function_name = attrs.function_name.as_deref().unwrap_or("Unknown function");
                        println!("  - Tool Call: {} ({})", function_name, success_str);

                        // Print arguments for specific tools
                        if function_name == "run_shell_command" {
                            if let Some(command) = event.other_attributes.get("command").and_then(|v| v.as_str()) {
                                println!("    - Command: {}", command);
                            }
                        }
                        else if function_name == "write_file" {
                            if let Some(path) = event.other_attributes.get("file_path").and_then(|v| v.as_str()) {
                                println!("    - File Path: {}", path);
                            }
                            if let Some(content) = event.other_attributes.get("content").and_then(|v| v.as_str()) {
                                let content_preview = content.chars().take(80).collect::<String>();
                                println!("    - Content (preview): {}...", content_preview);
                            }
                        }
                        else if function_name == "replace" {
                            if let Some(path) = event.other_attributes.get("file_path").and_then(|v| v.as_str()) {
                                println!("    - File Path: {}", path);
                            }
                            if let Some(old_string) = event.other_attributes.get("old_string").and_then(|v| v.as_str()) {
                                let old_string_preview = old_string.chars().take(40).collect::<String>();
                                println!("    - Old String (preview): {}...", old_string_preview);
                            }
                            if let Some(new_string) = event.other_attributes.get("new_string").and_then(|v| v.as_str()) {
                                let new_string_preview = new_string.chars().take(40).collect::<String>();
                                println!("    - New String (preview): {}...", new_string_preview);
                            }
                        }
                    }
                }
            }
        }
    }
}
