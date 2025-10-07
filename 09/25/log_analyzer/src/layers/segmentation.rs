use std::sync::Arc;
use crate::debug::StepTracer;

pub struct JsonExtractorLayer {
    pub min_json_len: Option<usize>,
    pub max_json_len: Option<usize>,
    pub total_json_len: usize,
    pub json_count: usize,
}

impl JsonExtractorLayer {
    pub fn new(_tracer: Arc<StepTracer>) -> Self {
        Self {
            min_json_len: None,
            max_json_len: None,
            total_json_len: 0,
            json_count: 0,
        }
    }

    pub fn extract_json_objects(&mut self, data: &[u8], boundaries: &[(usize, usize)]) -> Vec<String> {
        let mut json_objects = Vec::new();

        for &(start, end) in boundaries {
            if start >= end || end > data.len() || start > data.len() {
                // This boundary is invalid or out of bounds for the current data slice, skip it.
                continue;
            }
            if let Ok(s) = String::from_utf8(data[start..end].to_vec()) {
                let current_len = s.len();
                self.min_json_len = Some(self.min_json_len.map_or(current_len, |min| min.min(current_len)));
                self.max_json_len = Some(self.max_json_len.map_or(current_len, |max| max.max(current_len)));
                self.total_json_len += current_len;
                self.json_count += 1;
                json_objects.push(s);
            }
        }
        json_objects
    }
}
