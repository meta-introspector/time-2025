use std::env;
use std::fs::{self, File};
use std::io::BufReader;
use xml::reader::{EventReader, XmlEvent};
use svg_hir::{
    Svg, SvgElementEnum, Rect, Circle, Group, Text, Path, Ellipse,
    BoundingBox, Color, Transform, Style, MonsterElementKind,
    traits::maps_to_monster::MapsToMonster,
    prime_vector::PrimeMorphism,
};
use config_lib;
use monster_svg_morphism::analysis::{run_analysis, CharFrequencyAnalyzer};


// The Monster Group primes
const MONSTER_PRIMES: [u64; 15] = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 41, 47, 59, 71];

fn parse_primes_arg(s: &str) -> Result<Vec<u64>, String> {
    s.split(',')
        .map(|s| s.trim().parse::<u64>())
        .collect::<Result<Vec<u64>, _>>()
        .map_err(|e| format!("Failed to parse prime number: {}", e))
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let args: Vec<String> = env::args().collect();
    let mut hecke_amplify_enabled = false;
    let mut input_path_idx = 1;
    let mut find_similar_substring: Option<String> = None; // NEW: Flag for similarity search

    // Check for --analyze flag
    if args.len() > 1 && args[1] == "--analyze" {
        let current_dir = env::current_dir()?;
        println!("Running analysis on: {}", current_dir.display());

        let mut primes_to_analyze_vec = Vec::new();
        let primes_arg_start_idx = 2; // Start checking from argument after --analyze

        if args.len() > primes_arg_start_idx && args[primes_arg_start_idx] == "--primes" {
            if args.len() > primes_arg_start_idx + 1 {
                match parse_primes_arg(&args[primes_arg_start_idx + 1]) {
                    Ok(primes) => primes_to_analyze_vec = primes,
                    Err(e) => {
                        eprintln!("Error parsing --primes argument: {}", e);
                        return Err("Invalid --primes argument".into());
                    }
                }
            } else {
                eprintln!("Error: --primes argument requires a comma-separated list of numbers.");
                return Err("Missing value for --primes".into());
            }
        }

        // If no primes were provided via --primes, use MONSTER_PRIMES as default
        let primes_to_analyze: &[u64] = if primes_to_analyze_vec.is_empty() {
            &MONSTER_PRIMES
        } else {
            &primes_to_analyze_vec
        };

        let report = run_analysis(&current_dir, primes_to_analyze); // Use run_analysis from analysis module

        println!("\n--- Prime Resonance Analysis Report ---");
        if report.prime_occurrences.is_empty() {
            println!("No prime resonances found.");
        } else {
            // Sort primes for consistent output
            let mut sorted_primes: Vec<u64> = report.prime_occurrences.keys().cloned().collect();
            sorted_primes.sort_unstable();
            for prime in sorted_primes {
                if let Some(occurrences) = report.prime_occurrences.get(&prime) {
                    println!("Prime {}:", prime);
                    for occ in occurrences {
                        println!("  - {}", occ);
                    }
                }
            }
        }


        println!("\n--- Prime Factor Occurrences in Literals and String ASCII Sums ---");
        if report.prime_factor_occurrences.is_empty() {
            println!("No prime factor occurrences found.");
        } else {
            let mut sorted_factors: Vec<u64> = report.prime_factor_occurrences.keys().cloned().collect();
            sorted_factors.sort_unstable();
            for factor in sorted_factors {
                if let Some(occurrences) = report.prime_factor_occurrences.get(&factor) {
                    println!("Prime Factor {}:", factor);
                    for occ in occurrences {
                        println!("  - {}", occ);
                    }
                }
            }
        }

        println!("\n--- Recursive Cycles ---");
        if report.recursive_cycles.is_empty() {
            println!("No recursive cycles with configured prime lengths found.");
        } else {
            for (start_node, cycle) in report.recursive_cycles {
                println!("- Cycle starting at '{}' with length {}: {:?}", start_node, cycle.len(), cycle);
            }
        }

        println!("\n--- Symbol Table (Path to PrimeVector Embedding) ---");
        if report.symbol_table.is_empty() {
            println!("No symbolic embeddings generated.");
        } else {
            let mut sorted_paths: Vec<String> = report.symbol_table.keys().cloned().collect();
            sorted_paths.sort_unstable();
            for path in sorted_paths {
                if let Some(prime_vector) = report.symbol_table.get(&path) {
                    println!("Path: {}", path);
                    // Sort primes within the vector for consistent output
                    let mut sorted_primes: Vec<u64> = prime_vector.map.keys().cloned().collect();
                    sorted_primes.sort_unstable();
                    for prime in sorted_primes {
                        if let Some(coeff) = prime_vector.map.get(&prime) {
                            println!("  Prime {}: Coefficient {}", prime, coeff);
                        }
                    }
                }
            }
        }
        
        println!("\n--- Composite Prime Vectors (Conceptual Multiplication) ---");
        if report.composite_prime_vectors.is_empty() {
            println!("No composite prime vectors generated.");
        } else {
            let mut sorted_paths: Vec<String> = report.composite_prime_vectors.keys().cloned().collect();
            sorted_paths.sort_unstable();
            for path in sorted_paths {
                if let Some(prime_vector) = report.composite_prime_vectors.get(&path) {
                    println!("Parent Path: {}", path);
                    let mut sorted_primes: Vec<u64> = prime_vector.map.keys().cloned().collect();
                    sorted_primes.sort_unstable();
                    for prime in sorted_primes {
                        if let Some(coeff) = prime_vector.map.get(&prime) {
                            println!("  Prime {}: Coefficient {}", prime, coeff);
                        }
                    }
                }
            }
        }

        // NEW: Print Character Sequence Analysis
        println!("\n--- Character Pair Transition Frequencies ---");
        if report.char_pair_transitions.is_empty() {
            println!("No character pair transitions found.");
        } else {
            let mut sorted_pairs: Vec<((char, char), usize)> = report.char_pair_transitions.into_iter().collect();
            sorted_pairs.sort_by(|a, b| b.1.cmp(&a.1)); // Sort by frequency descending
            for (pair, count) in sorted_pairs.iter().take(20) { // Print top 20
                println!("  ('{}{}') -> {}", pair.0, pair.1, count);
            }
        }

        println!("\n--- N-gram Frequencies ---");
        if report.ngrams_frequencies.is_empty() {
            println!("No N-gram frequencies found.");
        } else {
            for (n, ngrams_map) in &report.ngrams_frequencies {
                println!("  N-grams of length {}:", n);
                let mut sorted_ngrams: Vec<(&String, &usize)> = ngrams_map.iter().collect();
                sorted_ngrams.sort_by(|a, b| b.1.cmp(&a.1)); // Sort by frequency descending
                for (ngram, count) in sorted_ngrams.iter().take(10) { // Print top 10 per N
                    println!("    '{}' -> {}", ngram, count);
                }
            }
        }

        return Ok(())
    }

    // NEW: Check for --find-similar flag
    if args.len() > input_path_idx {
        if args[input_path_idx] == "--find-similar" {
            if args.len() > input_path_idx + 1 {
                find_similar_substring = Some(args[input_path_idx + 1].clone());
                input_path_idx += 2; // Advance past flag and substring
            } else {
                eprintln!("Error: --find-similar requires a substring argument.");
                return Err("Missing value for --find-similar".into());
            }
        }
    }


    // --- Similarity Search Logic ---
    if let Some(target_substring) = find_similar_substring {
        let current_dir = env::current_dir()?;
        println!("Searching for substrings similar to '{}' in: {}", target_substring, current_dir.display());

        // We need the char_to_prime_map for PrimeMorphism
        let mut char_freq_analyzer = CharFrequencyAnalyzer::new();
        char_freq_analyzer.collect_char_frequencies(&current_dir);
        let char_to_prime_map = char_freq_analyzer.generate_char_to_prime_map();
        
        // Create a PrimeMorphism to generate PrimeVectors for the target and existing substrings
        let prime_morphism = PrimeMorphism::new(char_to_prime_map);

        let target_pv = prime_morphism.string_to_char_prime_vector(&target_substring);

        // Run analysis to get existing substring PrimeVectors
        let primes_to_analyze: &[u64] = &MONSTER_PRIMES; // Use default primes for this analysis
        let report = run_analysis(&current_dir, primes_to_analyze);
        
        if report.substring_prime_vectors.is_empty() {
            println!("No substring PrimeVectors generated in the report. Cannot perform similarity search.");
            return Ok(());
        }

        let mut similar_substrings: Vec<(String, f64)> = Vec::new();
        let similarity_threshold = 0.7; // Adjustable threshold

        for (substring, pv) in report.substring_prime_vectors {
            if substring == target_substring { // Don't compare with itself
                continue;
            }
            let similarity = target_pv.cosine_similarity(&pv);
            if similarity >= similarity_threshold {
                similar_substrings.push((substring, similarity));
            }
        }

        similar_substrings.sort_by(|a, b| b.1.partial_cmp(&a.1).unwrap_or(std::cmp::Ordering::Equal));

        println!("\n--- Similar Substrings (Similarity >= {:.2}) ---", similarity_threshold);
        if similar_substrings.is_empty() {
            println!("No similar substrings found.");
        } else {
            for (substring, similarity) in similar_substrings {
                println!("  '{}' (Similarity: {:.4})", substring, similarity);
            }
        }

        return Ok(());
    }


    // Check for --hecke-amplify flag
    // The flag can be at position 1 or 2 (if input_path_idx is already advanced by --analyze or --find-similar)
    if args.len() > input_path_idx {
        if args[input_path_idx] == "--hecke-amplify" {
            hecke_amplify_enabled = true;
            input_path_idx += 1; // Advance past flag
        }
    }


    if args.len() < input_path_idx {
        eprintln!("Usage: {} [--hecke-amplify]", args[0]);
        eprintln!("       {} --analyze [--primes <p1,p2,...>]", args[0]);
        eprintln!("       {} --find-similar <substring>", args[0]); // NEW: Add to usage
        return Err("Invalid arguments".into());
    }

    let (config, _) = match config_lib::find_and_read_config("lean_introspector/config.toml") {
        Ok(config) => config,
        Err(e) => {
            eprintln!("Failed to read config file: {}", e);
            std::process::exit(1);
        }
    };;

    for entry in fs::read_dir(config.dataset_path)? {
        let entry = entry?;
        let path = entry.path();
        if path.is_file() && path.extension().map_or(false, |ext| ext == "svg") {
            println!("Processing file: {}", path.display());
            let file = File::open(&path)?;
            let file = BufReader::new(file);

            let mut svg_root = svg_hir::svg_parser::parse_svg(file)?;

            apply_morphism(&mut svg_root, hecke_amplify_enabled);

            // The output is now printed to the console
            // let output_svg_string = svg_root.to_svg_string();
            // println!("{}", output_svg_string);
        }
    }

    Ok(())
}




fn apply_morphism(svg: &mut Svg, hecke_amplify: bool) {
    for child in &mut svg.children {
        apply_morphism_to_element(child, hecke_amplify);
    }
}

fn apply_morphism_to_element(element: &mut SvgElementEnum, hecke_amplify: bool) {
    let monster_kind = element.map_to_monster_element();
    let new_color = monster_color(&monster_kind);

    if hecke_amplify && monster_kind == MonsterElementKind::P71_1 {
        apply_hecke_effect(element);
    }

    let style = match element {
        SvgElementEnum::Rect(e) => &mut e.style,
        SvgElementEnum::Circle(e) => &mut e.style,
        SvgElementEnum::Ellipse(e) => &mut e.style,
        SvgElementEnum::Group(e) => {
            for child in &mut e.children {
                apply_morphism_to_element(child, hecke_amplify);
            }
            &mut e.style
        },
        SvgElementEnum::Text(e) => &mut e.style,
        SvgElementEnum::Path(e) => &mut e.style,
    };

    if style.is_none() {
        *style = Some(Style { fill: None, stroke: None, stroke_width: None });
    }
    if let Some(s) = style {
        s.fill = Some(new_color);
    }
}

fn apply_hecke_effect(element: &mut SvgElementEnum) {
    match element {
        SvgElementEnum::Rect(e) => {
            e.width *= 2.0;
            e.height *= 2.0;
            // Adjust position to keep center somewhat
            e.x -= e.width / 4.0;
            e.y -= e.height / 4.0;
        },
        SvgElementEnum::Circle(e) => {
            e.r *= 2.0;
        },
        SvgElementEnum::Ellipse(e) => {
            e.rx *= 2.0;
            e.ry *= 2.0;
        },
        SvgElementEnum::Text(e) => {
            // For text, just make it a distinct color for visibility for now
            if e.style.is_none() {
                e.style = Some(Style { fill: None, stroke: None, stroke_width: None });
            }
            if let Some(s) = &mut e.style {
                s.fill = Some(Color { r: 255, g: 255, b: 0, a: 255 }); // Bright yellow
            }
        },
        SvgElementEnum::Path(e) => {
            // Scaling path data is complex, for now, just change color
            if e.style.is_none() {
                e.style = Some(Style { fill: None, stroke: None, stroke_width: None });
            }
            if let Some(s) = &mut e.style {
                s.fill = Some(Color { r: 0, g: 255, b: 255, a: 255 }); // Cyan
            }
        },
        SvgElementEnum::Group(e) => {
            // Recursively apply to children
            for child in &mut e.children {
                apply_hecke_effect(child);
            }
        }
    }
}

fn monster_color(kind: &MonsterElementKind) -> Color {
    match kind {
        MonsterElementKind::P2_46 => Color { r: 255, g: 0, b: 0, a: 255 },
        MonsterElementKind::P3_20 => Color { r: 0, g: 255, b: 0, a: 255 },
        MonsterElementKind::P5_9 => Color { r: 0, g: 0, b: 255, a: 255 },
        MonsterElementKind::P7_6 => Color { r: 255, g: 255, b: 0, a: 255 },
        MonsterElementKind::P11_2 => Color { r: 255, g: 0, b: 255, a: 255 },
        MonsterElementKind::P13_3 => Color { r: 0, g: 255, b: 255, a: 255 },
        MonsterElementKind::P17_1 => Color { r: 128, g: 0, b: 0, a: 255 },
        MonsterElementKind::P19_1 => Color { r: 0, g: 128, b: 0, a: 255 },
        MonsterElementKind::P23_1 => Color { r: 0, g: 0, b: 128, a: 255 },
        MonsterElementKind::P29_1 => Color { r: 128, g: 128, b: 0, a: 255 },
        MonsterElementKind::P31_1 => Color { r: 128, g: 0, b: 128, a: 255 },
        MonsterElementKind::P41_1 => Color { r: 0, g: 128, b: 128, a: 255 },
        MonsterElementKind::P47_1 => Color { r: 128, g: 128, b: 128, a: 255 },
        MonsterElementKind::P59_1 => Color { r: 255, g: 128, b: 0, a: 255 },
        MonsterElementKind::P71_1 => Color { r: 255, g: 0, b: 128, a: 255 },
        MonsterElementKind::Unknown => Color { r: 0, g: 0, b: 0, a: 255 },
        MonsterElementKind::TextOnePart => Color { r: 200, g: 200, b: 200, a: 255 },
        MonsterElementKind::TextTwoParts => Color { r: 150, g: 150, b: 150, a: 255 },
        MonsterElementKind::TextThreeParts => Color { r: 100, g: 100, b: 100, a: 255 },
        MonsterElementKind::ExternalSystem => Color { r: 50, g: 50, b: 50, a: 255 },
    }
}


