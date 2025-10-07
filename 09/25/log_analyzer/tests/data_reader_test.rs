use std::fs::File;
use std::io::{self};
use std::time::Instant;
use std::sync::Arc;

use log_analyzer::layers::ingestion::RawDataIngestionLayer;
use log_analyzer::layers::segmentation::JsonExtractorLayer;
use log_analyzer::layers::buffer_management::BufferManagementLayer;
use log_analyzer::layers::json_boundary_detector::JsonBoundaryDetector;
use log_analyzer::debug::StepTracer;

/*
#[test]
fn test_data_reader_performance() -> io::Result<()> {
    use std::io::Cursor;

    let log_data = r#"
        {"timestamp": "2025-01-01T12:00:00Z", "level": "INFO", "message": "Test log entry 1"}
        {"timestamp": "2025-01-01T12:00:01Z", "level": "WARN", "message": "Test log entry 2"}
        {"timestamp": "2025-01-01T12:00:02Z", "level": "ERROR", "message": "Test log entry 3"}
    "#;
    let file = Cursor::new(log_data.as_bytes());

    let tracer = Arc::new(StepTracer::new(None)); // No max steps for this test
    let mut ingestion_layer = RawDataIngestionLayer::new(file, tracer.clone())?;
    let mut buffer_management_layer = log_analyzer::layers::buffer_management::BufferManagementLayer::new();
    let mut boundary_detector = JsonBoundaryDetector::new();
    let mut json_extractor_layer = JsonExtractorLayer::new(tracer.clone());

    let mut total_json_objects = 0;
    let start_time = Instant::now();
    let limit = Some(10); // Process only the first 10 JSON objects for the test

    let mut slow_json_objects: Vec<(usize, u128)> = Vec::new(); // (length, time_taken_micros)
    let slow_threshold_micros = 100; // Threshold for a "slow" JSON object (100 microseconds)

    loop {
        match ingestion_layer.read_chunk()? {
            Some(chunk) => {
                buffer_management_layer.extend_buffer(chunk);
                let current_buffered_data = buffer_management_layer.get_buffered_data();
                let boundaries = boundary_detector.detect_boundaries(current_buffered_data);
                let json_objects = json_extractor_layer.extract_json_objects(current_buffered_data, &boundaries);

                for json_string in json_objects {
                    let json_start_time = Instant::now();
                    // Simulate parsing to get a more accurate time for a "slow" line
                    let _ = serde_json::from_str::<serde_json::Value>(&json_string).ok();
                    let json_elapsed_time = json_start_time.elapsed().as_micros();

                    if json_elapsed_time > slow_threshold_micros {
                        slow_json_objects.push((json_string.len(), json_elapsed_time));
                    }

                    total_json_objects += 1;
                    if let Some(l) = limit {
                        if total_json_objects >= l {
                            break;
                        }
                    }
                }
                if let Some(l) = limit {
                    if total_json_objects >= l {
                        break;
                    }
                }
                // Consume data up to the end of the last detected boundary
                if let Some((_start, end)) = boundaries.last() {
                    buffer_management_layer.consume_data(*end);
                }
            },
            None => {
                // Process any remaining data in the buffer after EOF
                let current_buffered_data = buffer_management_layer.get_buffered_data();
                let boundaries = boundary_detector.detect_boundaries(current_buffered_data);
                let json_objects = json_extractor_layer.extract_json_objects(current_buffered_data, &boundaries);
                for json_string in json_objects {
                    let json_start_time = Instant::now();
                    let _ = serde_json::from_str::<serde_json::Value>(&json_string).ok();
                    let json_elapsed_time = json_start_time.elapsed().as_micros();

                    if json_elapsed_time > slow_threshold_micros {
                        slow_json_objects.push((json_string.len(), json_elapsed_time));
                    }
                    total_json_objects += 1;
                }
                break;
            },
        }
    }

    let elapsed_time = start_time.elapsed();

    println!("\n--- Data Reader Performance Test Results ---");
    println!("Log file: {}", log_file_path);
    println!("Total JSON objects segmented (limited to {}): {}", limit.unwrap_or(total_json_objects), total_json_objects);
    println!("Total time taken: {:?}", elapsed_time);
    println!("Min JSON object length: {:?} bytes", json_extractor_layer.min_json_len);
    println!("Max JSON object length: {:?} bytes", json_extractor_layer.max_json_len);
    if json_extractor_layer.json_count > 0 {
        println!("Average JSON object length: {:.2} bytes", json_extractor_layer.total_json_len as f64 / json_extractor_layer.json_count as f64);
    }

    if !slow_json_objects.is_empty() {
        println!("\n--- Slow JSON Objects (processing time > {} microseconds) ---", slow_threshold_micros);
        for (len, time) in slow_json_objects {
            println!("  Length: {} bytes, Time: {} microseconds", len, time);
        }
    } else {
        println!("\nNo slow JSON objects found (processing time > {} microseconds).", slow_threshold_micros);
    }

    Ok(())
}
*/
