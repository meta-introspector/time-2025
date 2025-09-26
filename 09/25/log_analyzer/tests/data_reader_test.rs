use std::fs::File;
use std::io::{self, Write};
use std::time::Instant;
use std::sync::Arc;

use log_analyzer::layers::ingestion::RawDataIngestionLayer;
use log_analyzer::layers::segmentation::JsonObjectSegmentationLayer;
use log_analyzer::debug::StepTracer;

#[test]
fn test_data_reader_performance() -> io::Result<()> {
    let log_file_path = "/data/data/com.termux.nix/files/home/pick-up-nix2/gemini-cli/.gemini/telemetry.log";
    let file = File::open(log_file_path)?;

    let tracer = Arc::new(StepTracer::new(None)); // No max steps for this test
    let mut ingestion_layer = RawDataIngestionLayer::new(file, tracer.clone())?;
    let mut segmentation_layer = JsonObjectSegmentationLayer::new(tracer.clone());

    let mut total_json_objects = 0;
    let start_time = Instant::now();
    let limit = Some(10); // Process only the first 10 JSON objects for the test

    let mut slow_json_objects: Vec<(usize, u128)> = Vec::new(); // (length, time_taken_micros)
    let slow_threshold_micros = 100; // Threshold for a "slow" JSON object (100 microseconds)

    loop {
        match ingestion_layer.read_chunk()? {
            Some(chunk) => {
                let json_objects = segmentation_layer.process_chunk(chunk);
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
            },
            None => break,
        }
    }

    let elapsed_time = start_time.elapsed();

    println!("\n--- Data Reader Performance Test Results ---");
    println!("Log file: {}", log_file_path);
    println!("Total JSON objects segmented (limited to {}): {}", limit.unwrap_or(total_json_objects), total_json_objects);
    println!("Total time taken: {:?}", elapsed_time);
    println!("Min JSON object length: {:?} bytes", segmentation_layer.min_json_len);
    println!("Max JSON object length: {:?} bytes", segmentation_layer.max_json_len);
    if segmentation_layer.json_count > 0 {
        println!("Average JSON object length: {:.2} bytes", segmentation_layer.total_json_len as f64 / segmentation_layer.json_count as f64);
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
