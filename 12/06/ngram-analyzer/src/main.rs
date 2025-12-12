use std::fs;
use std::collections::{HashMap, BTreeMap};
use std::path::PathBuf;
use roxmltree::{Document, Node};
use serde::Serialize;
use unicode_segmentation::UnicodeSegmentation;
use std::f64; // For f64::log

// Define the Monster Group primes and their exponents
const MONSTER_GROUP_PRIMES_AND_EXPONENTS: &[(u64, u32)] = &[
    (2, 46), (3, 20), (5, 9), (7, 6), (11, 2), (13, 3), (17, 1),
    (19, 1), (23, 1), (29, 1), (31, 1), (41, 1), (47, 1), (59, 1), (71, 1),
];

#[derive(Serialize, Debug)]
struct MappedNgram {
    ngram: String,
    frequency: u32,
    mapped_prime: u64,
    prime_exponent: u32,
}

#[derive(Serialize)]
struct NgramReport {
    emoji_bigrams: HashMap<String, u32>,
    word_2grams: HashMap<String, u32>,
    word_3grams: HashMap<String, u32>,
    word_5grams: HashMap<String, u32>,
    word_7grams: HashMap<String, u32>,
    
    ranked_ngrams: Vec<(String, u32)>, // Globally ranked n-grams
    monster_mapped_ngrams: Vec<MappedNgram>, // Top 108 mapped to Monster primes
    monster_backpack_filling_score: f64, // The calculated score
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let mut args = pico_args::Arguments::from_env();

    let input_svg_path: PathBuf = args.value_from_os_str("--input", parse_path)
        .map_err(|_| "Missing --input <SVG_FILE_PATH>")?;
    let output_json_path: PathBuf = args.value_from_os_str("--output", parse_path)
        .map_err(|_| "Missing --output <JSON_FILE_PATH>")?;

    let svg_data = fs::read_to_string(&input_svg_path)?;
    let doc = Document::parse(&svg_data)?;

    let mut all_text = String::new();
    collect_text_nodes(&doc.root(), &mut all_text);

    // --- N-gram generation ---
    let emoji_bigrams = generate_emoji_bigrams(&all_text);
    let word_2grams = generate_word_ngrams(&all_text, 2);
    let word_3grams = generate_word_ngrams(&all_text, 3);
    let word_5grams = generate_word_ngrams(&all_text, 5);
    let word_7grams = generate_word_ngrams(&all_text, 7);

    // --- Global ranking ---
    let mut all_ngrams_with_freq: Vec<(String, u32)> = Vec::new();
    for (ngram, freq) in &emoji_bigrams {
        all_ngrams_with_freq.push((ngram.clone(), *freq));
    }
    for (ngram, freq) in &word_2grams {
        all_ngrams_with_freq.push((ngram.clone(), *freq));
    }
    for (ngram, freq) in &word_3grams {
        all_ngrams_with_freq.push((ngram.clone(), *freq));
    }
    for (ngram, freq) in &word_5grams {
        all_ngrams_with_freq.push((ngram.clone(), *freq));
    }
    for (ngram, freq) in &word_7grams {
        all_ngrams_with_freq.push((ngram.clone(), *freq));
    }

    // Sort by frequency descending
    all_ngrams_with_freq.sort_by(|a, b| b.1.cmp(&a.1));

    // --- Monster Group Mapping and Score Calculation ---
    let mut monster_mapped_ngrams: Vec<MappedNgram> = Vec::new();
    let mut current_ngram_index = 0;
    let mut monster_backpack_filling_score = 0.0;

    for &(prime, exponent) in MONSTER_GROUP_PRIMES_AND_EXPONENTS.iter() {
        for _ in 0..exponent {
            if let Some((ngram, frequency)) = all_ngrams_with_freq.get(current_ngram_index) {
                monster_mapped_ngrams.push(MappedNgram {
                    ngram: ngram.clone(),
                    frequency: *frequency,
                    mapped_prime: prime,
                    prime_exponent: exponent, // Store the original exponent for context
                });
                // Calculate score: frequency * log(prime). Using f64::log for natural logarithm.
                monster_backpack_filling_score += (*frequency as f64) * (prime as f64).log(f64::consts::E);
                current_ngram_index += 1;
            } else {
                // Not enough n-grams to fill all slots, break early
                break;
            }
        }
    }


    let report = NgramReport {
        emoji_bigrams,
        word_2grams,
        word_3grams,
        word_5grams,
        word_7grams,
        ranked_ngrams: all_ngrams_with_freq,
        monster_mapped_ngrams,
        monster_backpack_filling_score,
    };

    let json_content = serde_json::to_string_pretty(&report)?;

    if let Some(parent) = output_json_path.parent() {
        fs::create_dir_all(parent)?;
    }
    fs::write(&output_json_path, json_content)?;

    println!("N-gram report written to {}", output_json_path.display());

    Ok(())
}

fn collect_text_nodes(node: &Node, all_text: &mut String) {
    if node.is_text() {
        if let Some(text) = node.text() {
            all_text.push_str(text);
            all_text.push(' ');
        }
    }

    for child in node.children() {
        collect_text_nodes(&child, all_text);
    }
}

fn generate_emoji_bigrams(text: &str) -> HashMap<String, u32> {
    let emojis: Vec<&str> = text.graphemes(true).filter(|g| is_emoji(g)).collect();
    let mut bigrams = HashMap::new();

    for i in 0..emojis.len().saturating_sub(1) {
        let bigram = format!("{} {}", emojis[i], emojis[i+1]);
        *bigrams.entry(bigram).or_insert(0) += 1;
    }

    bigrams
}

fn generate_word_ngrams(text: &str, n: usize) -> HashMap<String, u32> {
    let words: Vec<&str> = text.split_whitespace().collect();
    let mut ngrams = HashMap::new();

    if words.len() < n {
        return ngrams;
    }

    for i in 0..=words.len() - n {
        let ngram = words[i..i+n].join(" ");
        *ngrams.entry(ngram).or_insert(0) += 1;
    }

    ngrams
}

// A simple heuristic to identify emojis.
// This is not perfect but should work for many common emojis.
fn is_emoji(g: &str) -> bool {
    let first_char = g.chars().next().unwrap();
    // This is a very broad range and might catch non-emojis.
    // A more robust solution would use a proper emoji property database.
    (first_char >= '\u{1F300}' && first_char <= '\u{1F6FF}') ||
    (first_char >= '\u{2600}' && first_char <= '\u{26FF}') ||
    (first_char >= '\u{2700}' && first_char <= '\u{27BF}')
}

fn parse_path(s: &std::ffi::OsStr) -> Result<PathBuf, &'static str> {
    Ok(s.into())
}