// src/traits/has_embedded_primes.rs
use regex::Regex;
use lazy_static::lazy_static;
use crate::types::keys::MONSTER_GROUP_ORDER_STR; // Import the large prime string

pub trait HasEmbeddedPrimes {
    fn find_embedded_primes(&self, primes_to_check: &[u64]) -> Vec<(u64, String)>;
}

impl HasEmbeddedPrimes for &str {
    fn find_embedded_primes(&self, primes_to_check: &[u64]) -> Vec<(u64, String)> {
        lazy_static! {
            static ref RE: Regex = Regex::new(r"\d+").unwrap();
        }

        let mut found_primes = Vec::new();

        for mat in RE.find_iter(self) {
            let num_str = mat.as_str();

            // Try parsing as u64
            if let Ok(num) = num_str.parse::<u64>() {
                if primes_to_check.contains(&num) {
                    found_primes.push((num, format!("Found embedded prime {} in '{}'", num, self)));
                }
            } else {
                // Number is too large for u64, or parsing failed for other reasons.
                // Compare as string to large known primes (e.g., Monster Group order)
                // We'll extend this to include other large primes later if needed.
                if num_str == MONSTER_GROUP_ORDER_STR {
                    // For the Monster Group order, we can't represent it as u64,
                    // so we use a placeholder or special value, e.g., 0, and
                    // indicate it's a large number.
                    found_primes.push((0, format!("Found Monster Group order '{}' embedded in '{}'", MONSTER_GROUP_ORDER_STR, self)));
                }
            }
        }
        found_primes
    }
}
