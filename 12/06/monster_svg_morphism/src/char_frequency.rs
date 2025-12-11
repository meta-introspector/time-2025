use std::collections::HashMap;
use std::path::Path;
use crate::code_parser::{collect_code_elements_from_dir};
use svg_hir::prime_vector::{PrimeGenerator};

pub struct CharFrequencyAnalyzer {
    char_frequencies: HashMap<char, usize>,
}

impl CharFrequencyAnalyzer {
    pub fn new() -> Self {
        CharFrequencyAnalyzer {
            char_frequencies: HashMap::new(),
        }
    }

    pub fn collect_char_frequencies(&mut self, root_path: &Path) {
        let code_elements = collect_code_elements_from_dir(root_path);
        for element in code_elements {
            for ch in element.name.chars() {
                *self.char_frequencies.entry(ch).or_insert(0) += 1;
            }
            // Also consider characters in associated_idents (field/variant names)
            for ident in element.associated_idents {
                for ch in ident.chars() {
                    *self.char_frequencies.entry(ch).or_insert(0) += 1;
                }
            }
        }
    }

    pub fn generate_char_to_prime_map(self) -> HashMap<char, u64> {
        let mut sorted_chars: Vec<(char, usize)> = self.char_frequencies.into_iter().collect();
        // Sort by frequency (descending) then by char (ascending) for deterministic order
        sorted_chars.sort_by(|a, b| b.1.cmp(&a.1).then_with(|| a.0.cmp(&b.0)));

        let mut char_to_prime = HashMap::new();
        let mut prime_generator = PrimeGenerator::new(); // Each call gets a fresh generator
        
        for (ch, _freq) in sorted_chars {
            char_to_prime.insert(ch, prime_generator.get_next_prime());
        }
        char_to_prime
    }
}