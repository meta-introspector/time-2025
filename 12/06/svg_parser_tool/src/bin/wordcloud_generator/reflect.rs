use svg_parser_tool::processors::{ExtractedData, PRIMES_TO_ANALYZE};

pub fn reflect(extracted_data: &ExtractedData) {
    // Example: Print some extracted data
    println!("Total terms extracted: {}", extracted_data.terms.len());
    println!("Total relationships extracted: {}", extracted_data.relationships.len());
    
    println!("Running prime power counts:");
    for &prime in PRIMES_TO_ANALYZE {
        if let Some(&count) = extracted_data.prime_power_counts.get(&prime) {
            println!("  Prime {}: {}", prime, count);
        }
    }
}
