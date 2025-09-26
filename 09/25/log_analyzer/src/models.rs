use serde_json::{Value};
use std::collections::HashMap;

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

// The ExprObject enum representing the recursive structure of log data
#[derive(Debug, Clone, PartialEq, Eq, serde::Serialize, serde::Deserialize)]
pub enum ExprObject {
    Scalar(Value),
    Object(HashMap<String, ExprObject>),
    Array(Vec<ExprObject>),
}

#[derive(Debug, Clone)]
pub struct LogEntry {
    pub timestamp: Option<String>,
    pub event: Option<Event>,
    pub all_fields: ExprObject,
}
