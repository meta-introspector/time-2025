
pub struct BufferManagementLayer {
    buffer: Vec<u8>,
}

impl BufferManagementLayer {
    pub fn new() -> Self {
        Self {
            buffer: Vec::new(),
        }
    }

    pub fn extend_buffer(&mut self, chunk: &[u8]) {
        self.buffer.extend_from_slice(chunk);
    }

    pub fn get_buffered_data(&self) -> &[u8] {
        &self.buffer
    }

    pub fn consume_data(&mut self, count: usize) {
        self.buffer.drain(..count);
    }

    pub fn is_empty(&self) -> bool {
        self.buffer.is_empty()
    }
}
