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
        let mut local_start_index = 0; // Start index relative to the current data_chunk

        for (i, &byte) in data_chunk.iter().enumerate() {
            match byte as char {
                '{' => self.brace_count += 1,
                '}' => self.brace_count -= 1,
                _ => {},
            }

            if self.brace_count == 0 && local_start_index < i + 1 {
                // Found a complete JSON object boundary relative to data_chunk
                new_boundaries.push((local_start_index, i + 1));
                local_start_index = i + 1;
            }
        }
        // The remaining part of the data_chunk is the start of the next potential JSON object
        self.start_index = local_start_index;

        new_boundaries
    }

    // Resets the detector's internal state
    pub fn reset(&mut self) {
        self.brace_count = 0;
        self.start_index = 0;
        self.detected_boundaries.clear();
    }
}
