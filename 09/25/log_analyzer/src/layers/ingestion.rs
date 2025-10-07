use std::io::{self, BufReader, Read};
use std::sync::Arc;
use crate::debug::StepTracer;

pub struct RawDataIngestionLayer {
    reader: BufReader<std::fs::File>,
    buffer: Vec<u8>,
    buffer_pos: usize,
}

impl RawDataIngestionLayer {
    pub fn new(file: std::fs::File, _tracer: Arc<StepTracer>) -> io::Result<Self> {
        Ok(Self {
            reader: BufReader::new(file),
            buffer: vec![0; 25 * 1024], // 25KB buffer (5 times average JSON object size)
            buffer_pos: 0,
        })
    }

    pub fn read_chunk(&mut self) -> io::Result<Option<&[u8]>> {
        let bytes_read = self.reader.read(&mut self.buffer)?;
        if bytes_read == 0 {
            Ok(None)
        } else {
            self.buffer_pos = bytes_read;
            Ok(Some(&self.buffer[..bytes_read]))
        }
    }
}
