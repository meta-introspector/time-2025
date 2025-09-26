use std::sync::Arc;
use crate::debug::StepTracer;

pub struct JsonObjectSegmentationLayer {
    buffer: Vec<u8>,
    brace_count: i32,
    start_index: usize,
    tracer: Arc<StepTracer>,
    pub min_json_len: Option<usize>,
    pub max_json_len: Option<usize>,
    pub total_json_len: usize,
    pub json_count: usize,
}

impl JsonObjectSegmentationLayer {
    pub fn new(tracer: Arc<StepTracer>) -> Self {
        Self {
            buffer: Vec::new(),
            brace_count: 0,
            start_index: 0,
            tracer,
            min_json_len: None,
            max_json_len: None,
            total_json_len: 0,
            json_count: 0,
        }
    }

    pub fn process_chunk(&mut self, chunk: &[u8]) -> Vec<String> {
        self.buffer.extend_from_slice(chunk);
        let mut json_objects = Vec::new();
        let mut i = self.start_index;

        while i < self.buffer.len() {
            match self.buffer[i] as char {
                '{' => self.brace_count += 1,
                '}' => self.brace_count -= 1,
                _ => {},
            }

            if self.brace_count == 0 && self.start_index < i + 1 {
                // Found a complete JSON object
                if let Ok(s) = String::from_utf8(self.buffer[self.start_index..i + 1].to_vec()) {
                    let current_len = s.len();
                    self.min_json_len = Some(self.min_json_len.map_or(current_len, |min| min.min(current_len)));
                    self.max_json_len = Some(self.max_json_len.map_or(current_len, |max| max.max(current_len)));
                    self.total_json_len += current_len;
                    self.json_count += 1;
                    json_objects.push(s);
                }
                self.start_index = i + 1;
            }
            i += 1;
        }
        // If there's incomplete JSON at the end, move it to the beginning of the buffer
        if self.start_index < self.buffer.len() {
            let remaining = self.buffer.split_off(self.start_index);
            self.buffer = remaining;
            self.start_index = 0;
        } else {
            self.buffer.clear();
            self.start_index = 0;
        }
        json_objects
    }
}
