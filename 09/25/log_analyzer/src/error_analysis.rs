use std::collections::HashMap;
use crate::models::{ApiError, GeminiCliApiErrorAttributes};
use crate::debug::StepTracer;

#[derive(Debug, Hash, PartialEq, Eq, Clone)]
pub enum LogError {
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


pub fn analyze_errors(all_log_entries: &[crate::models::LogEntry], tracer: std::sync::Arc<StepTracer>) -> (HashMap<LogError, usize>, Vec<String>) {
    let error_keywords = regex::Regex::new(r"(?i)error|exception|denied|refused|timeout|panic|fail").unwrap();
    let input_token_limit_regex = regex::Regex::new(r"The input token count \((\d+)\) exceeds the maximum number of tokens allowed \((\d+)\).").unwrap();

    let mut error_counts: HashMap<LogError, usize> = HashMap::new();
    let mut unclassified_errors: Vec<String> = Vec::new();

    for entry in all_log_entries {
        tracer.step("Analyzing an error");

        let mut classified = false;

        if let crate::models::ExprObject::Object(ref obj) = entry.all_fields {
            if let Some(body_expr) = obj.get("_body") {
                if let crate::models::ExprObject::Scalar(serde_json::Value::String(body)) = body_expr {
                    if let Some(caps) = input_token_limit_regex.captures(body) {
                        if let (Ok(current), Ok(max)) = (caps[1].parse::<u64>(), caps[2].parse::<u64>()) {
                            *error_counts.entry(LogError::InputTokenLimitExceeded { current, max }).or_insert(0) += 1;
                            classified = true;
                        }
                    }
                    if body.contains("AbortError") {
                        *error_counts.entry(LogError::AbortError).or_insert(0) += 1;
                        classified = true;
                    } else if body.contains("Counts retries due to content errors") {
                        *error_counts.entry(LogError::ContentRetryError(body.to_string())).or_insert(0) += 1;
                        classified = true;
                    } else if body.contains("gemini_cli.api_error") {
                        *error_counts.entry(LogError::ApiError(body.to_string())).or_insert(0) += 1;
                        classified = true;
                    } else if body.contains("\"error_type\": \"Error\"") {
                        *error_counts.entry(LogError::GenericError).or_insert(0) += 1;
                        classified = true;
                    }
                }
            }

            if let Some(json_string_representation_expr) = obj.get("json_string_representation") {
                if let crate::models::ExprObject::Scalar(serde_json::Value::String(json_string)) = json_string_representation_expr {
                    if json_string.contains("\"failed\": false") {
                        *error_counts.entry(LogError::FalsePositiveFailedStatus).or_insert(0) += 1;
                        classified = true;
                    }

                    if !classified && error_keywords.is_match(json_string) {
                        unclassified_errors.push(json_string.to_string());
                        classified = true;
                    }
                }
            }

            if let Some(message_expr) = obj.get("message") {
                if let crate::models::ExprObject::Scalar(serde_json::Value::String(message)) = message_expr {
                    if message.contains("\"failed\": false") {
                        *error_counts.entry(LogError::FalsePositiveFailedStatus).or_insert(0) += 1;
                        classified = true;
                    } else if error_keywords.is_match(message) {
                        *error_counts.entry(LogError::PlainTextError(message.to_string())).or_insert(0) += 1;
                        classified = true;
                    }
                }
            }
        }

        if let Some(event) = &entry.event {
            match event.name {
                crate::models::EventName::GeminiCliChatContentRetryFailureCount => {
                    *error_counts.entry(LogError::ContentRetryFailureEvent).or_insert(0) += 1;
                    classified = true;
                },
                crate::models::EventName::GeminiCliApiError => {
                    if let Ok(api_attrs) = serde_json::from_value::<crate::models::GeminiCliApiErrorAttributes>(serde_json::Value::Object(event.other_attributes.clone())) {
                        *error_counts.entry(LogError::GeminiCliApiError(api_attrs)).or_insert(0) += 1;
                        classified = true;
                    } else {
                        *error_counts.entry(LogError::ApiError(format!("Failed to parse GeminiCliApiErrorAttributes: {:?}", event.other_attributes))).or_insert(0) += 1;
                        classified = true;
                    }
                },
                crate::models::EventName::GeminiCliToolCall => {
                    if let Ok(attrs) = serde_json::from_value::<crate::models::ToolCallAttributes>(serde_json::Value::Object(event.other_attributes.clone())) {
                        if let Some(success) = attrs.success {
                            if !success {
                                *error_counts.entry(LogError::UnfinishedToolCall(format!("Tool call failed: {:?}", attrs.function_name))).or_insert(0) += 1;
                                classified = true;
                            }
                        }
                    } else {
                        *error_counts.entry(LogError::ApiError(format!("Failed to parse ToolCallAttributes: {:?}", event.other_attributes))).or_insert(0) += 1;
                        classified = true;
                    }
                },
                _ => {} // Handle other event names if needed
            }
        }

        // If not classified by specific rules, and contains error keywords, add to unclassified
        if !classified {
            if let crate::models::ExprObject::Object(ref obj) = entry.all_fields {
                if let Some(message_expr) = obj.get("message") {
                    if let crate::models::ExprObject::Scalar(serde_json::Value::String(message)) = message_expr {
                        if error_keywords.is_match(message) {
                            unclassified_errors.push(message.to_string());
                        }
                    }
                }
            }
        }
    }
    (error_counts, unclassified_errors)
}
