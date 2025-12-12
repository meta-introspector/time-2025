// src/types/prime_vector.rs
use std::collections::HashMap;
use std::sync::Mutex;
use serde::{Serialize, Deserialize};

lazy_static::lazy_static! {
    static ref PRIME_GENERATOR: Mutex<PrimeGenerator> = Mutex::new(PrimeGenerator::new());
}

pub struct PrimeGenerator {
    current_prime_index: usize,
    primes: Vec<u64>,
}

impl PrimeGenerator {
    pub fn new() -> Self {
        // Precompute a reasonable number of primes using a simple sieve
        let limit = 100000; // Generate primes up to this limit (increased for more components)
        let mut is_prime = vec![true; limit + 1];
        is_prime[0] = false;
        is_prime[1] = false;
        for p in 2..=limit {
            if is_prime[p] {
                for multiple in (p * p)..=limit {
                    if multiple % p == 0 {
                        is_prime[multiple] = false;
                    }
                }
            }
        }
        let primes = (2..=limit).filter(|&p| is_prime[p]).map(|p| p as u64).collect();
        PrimeGenerator {
            current_prime_index: 0,
            primes,
        }
    }

    pub fn get_next_prime(&mut self) -> u64 {
        if self.current_prime_index >= self.primes.len() {
            // Should ideally extend the list if more primes are needed
            // For now, panic or return a placeholder to indicate exhaustion
            panic!("PrimeGenerator exhausted. Need to extend the precomputed list.");
        }
        let prime = self.primes[self.current_prime_index];
        self.current_prime_index += 1;
        prime
    }
}


/// Represents a vector of primes with coefficients, where the key is the prime
/// and the value is its coefficient.
#[derive(Debug, Clone, PartialEq, Eq, Serialize, Deserialize)] // Added Serialize, Deserialize
pub struct PrimeVector {
    #[serde(with = "crate::serde_map_u64_key")]
    pub map: HashMap<u64, u64>,
}

impl PrimeVector {
    pub fn new() -> Self {
        PrimeVector {
            map: HashMap::new(),
        }
    }

    /// Multiplies the vector by adding coefficients.
    pub fn multiply(&mut self, other: &PrimeVector) {
        for (prime, coeff) in &other.map {
            *self.map.entry(*prime).or_insert(0) += coeff;
        }
    }

    /// Scalar multiplication (coefficient scaling).
    pub fn scale(&mut self, factor: u64) {
        for (_prime, coeff) in &mut self.map {
            *coeff *= factor;
        }
    }

    /// Calculates the cosine similarity between two PrimeVectors.
    /// Returns a value between 0.0 and 1.0.
    pub fn cosine_similarity(&self, other: &PrimeVector) -> f64 {
        let dot_product: f64 = self.map.iter().filter_map(|(prime, &coeff_self)| {
            other.map.get(prime).map(|&coeff_other| (coeff_self as f64) * (coeff_other as f64))
        }).sum();

        let magnitude_self: f64 = self.map.values().map(|&coeff| (coeff as f64).powi(2)).sum();
        let magnitude_other: f64 = other.map.values().map(|&coeff| (coeff as f64).powi(2)).sum();

        if magnitude_self == 0.0 || magnitude_other == 0.0 {
            return 0.0; // Avoid division by zero, no similarity if one vector is empty
        }

        dot_product / (magnitude_self.sqrt() * magnitude_other.sqrt())
    }
}

impl Default for PrimeVector {
    fn default() -> Self {
        Self::new()
    }
}

/// Manages the assignment of unique primes to string components.
#[derive(Debug, Serialize, Deserialize)] // Added Serialize, Deserialize
pub struct PrimeMorphism {
    component_to_prime: HashMap<String, u64>,
    char_to_prime_map: HashMap<char, u64>,
}

impl PrimeMorphism {
    pub fn new(char_to_prime_map: HashMap<char, u64>) -> Self {
        PrimeMorphism {
            component_to_prime: HashMap::new(),
            char_to_prime_map, // Initialize with the provided map
        }
    }

    /// Gets the prime for a given component, assigning a new one if not already present.
    /// This is primarily for predicates and other non-character-based prime assignments.
    pub fn get_prime_for_component(&mut self, component: &str) -> u64 {
        let mut generator = PRIME_GENERATOR.lock().unwrap();
        *self.component_to_prime.entry(component.to_string()).or_insert_with(|| generator.get_next_prime())
    }

    /// Converts a string into a PrimeVector based on its characters' primes.
    pub fn string_to_char_prime_vector(&self, s: &str) -> PrimeVector {
        let mut pv = PrimeVector::new();
        for ch in s.chars() {
            if let Some(&prime) = self.char_to_prime_map.get(&ch) {
                *pv.map.entry(prime).or_insert(0) += 1;
            }
        }
        pv
    }

    /// Converts a path (Vec<String>) into a PrimeVector.
    /// The coefficient of each prime is based on its depth in the path (e.g., higher depth, higher coeff).
    /// It now incorporates character-based prime vectors for component names.
    pub fn path_to_prime_vector(&mut self, path: &[String]) -> PrimeVector {
        let mut prime_vector = PrimeVector::new();

        for (depth, component) in path.iter().enumerate() {
            let parts: Vec<&str> = component.split("::").collect();
            let (component_type, component_name) = if parts.len() > 1 {
                (parts[0], parts[1..].join("::"))
            } else {
                ("raw", component.clone()) // Handle "crate" or other raw components
            };

            // Get character-based PrimeVector for the component name
            let char_pv_for_name = self.string_to_char_prime_vector(&component_name);
            
            let type_weight = self.get_type_weight(component_type);
            // Coefficient based on depth + type_weight
            let scaling_factor = (depth + 1) as u64 + type_weight;
            
            let mut scaled_char_pv_for_name = char_pv_for_name;
            scaled_char_pv_for_name.scale(scaling_factor); // Scale the character-based PV

            prime_vector.multiply(&scaled_char_pv_for_name); // Multiply into the path's PrimeVector
        }
        prime_vector
    }

    // Helper function to assign weights based on component type
    fn get_type_weight(&self, component_type: &str) -> u64 {
        match component_type {
            "crate" => 10,    // High weight for the crate root
            "mod" => 5,     // Modules are significant
            "fn" => 3,      // Functions are core logic
            "struct" => 2,  // Structs define data structures
            "enum" => 2,    // Enums define data structures
            "const" => 1,   // Constants are values
            "raw" => 1,     // Default for unknown or raw components
            _ => 0,         // Fallback
        }
    }
}
