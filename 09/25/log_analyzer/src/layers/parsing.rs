use std::sync::Arc;
use crate::debug::StepTracer;
use crate::models::ExprObject;
use std::collections::HashMap;
use serde_json::Value;

const MAX_DEPTH: usize = 3; // Example max depth, can be configured

pub struct JsonParsingLayer {
    tracer: Arc<StepTracer>,
}

impl JsonParsingLayer {
    pub fn new(tracer: Arc<StepTracer>) -> Self { Self { tracer } }

    pub fn parse_json(&self, json_string: &str) -> Option<ExprObject> {
        self.tracer.step("Parsing JSON string");
        let value: Value = serde_json::from_str(json_string).ok()?;
        Some(value_to_expr_object(value, 0))
    }
}

fn value_to_expr_object(value: Value, current_depth: usize) -> ExprObject {
    if current_depth >= MAX_DEPTH {
        return ExprObject::Scalar(Value::String("[TRUNCATED_DEPTH]".to_string()));
    }

    match value {
        Value::Null | Value::Bool(_) | Value::Number(_) | Value::String(_) => ExprObject::Scalar(value),
        Value::Array(arr) => {
            // Determine the allowed size for the array from ZOS_TYPES
            let allowed_size = [0, 1, 2, 3, 5, 7, 11, 13, 17, 19].iter().filter(|&&s| s <= arr.len()).max().unwrap_or(&0).clone();
            let limited_arr: Vec<ExprObject> = arr.into_iter()
                .take(allowed_size)
                .map(|v| value_to_expr_object(v, current_depth + 1))
                .collect();
            ExprObject::Array(limited_arr)
        },
        Value::Object(obj) => {
            // Determine the allowed size for the object from ZOS_TYPES
            let allowed_size = [0, 1, 2, 3, 5, 7, 11, 13, 17, 19].iter().filter(|&&s| s <= obj.len()).max().unwrap_or(&0).clone();
            let mut expr_map = HashMap::new();
            for (key, val) in obj.into_iter().take(allowed_size) {
                expr_map.insert(key, value_to_expr_object(val, current_depth + 1));
            }
            ExprObject::Object(expr_map)
        },
    }
}
