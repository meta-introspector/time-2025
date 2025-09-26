use std::collections::VecDeque;

pub struct JsonBoundaryDetector {
    brace_count: i32,
    start_index: usize,
    // Store detected boundaries as (start, end) byte indices
    detected_boundaries: VecDeque<(usize, usize)>,
}

impl JsonBoundaryDetector {
    pub fn new() -> Self {
        Self {
            brace_count: 0,
            start_index: 0,
            detected_boundaries: VecDeque::new(),
        }
    }

    // Processes a chunk of data and updates internal state, returning new complete boundaries
    pub fn detect_boundaries(&mut self, data_chunk: &[u8]) -> Vec<(usize, usize)> {
        let mut new_boundaries = Vec::new();
        let current_buffer_len = self.start_index + data_chunk.len();

        for (i, &byte) in data_chunk.iter().enumerate() {
            let global_index = self.start_index + i;

            match byte as char {
                '{' => self.brace_count += 1,
                '}' => self.brace_count -= 1,
                _ => {},
            }

            if self.brace_count == 0 && self.start_index < global_index + 1 {
                // Found a complete JSON object boundary
                new_boundaries.push((self.start_index, global_index + 1));
                self.start_index = global_index + 1;
            }
        }
        // Update start_index for the next chunk based on what's been processed
        self.start_index = current_buffer_len - (self.start_index - self.detected_boundaries.front().map_or(0, |&(s, _)| s));

        new_boundaries
    }

    // Resets the detector's internal state
    pub fn reset(&mut self) {
        self.brace_count = 0;
        self.start_index = 0;
        self.detected_boundaries.clear();
    }
}
