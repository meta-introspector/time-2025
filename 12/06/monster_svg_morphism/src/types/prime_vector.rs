// src/types/prime_vector.rs
use std::collections::HashMap;
use std::sync::Mutex;

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
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct PrimeVector {
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
}

impl Default for PrimeVector {
    fn default() -> Self {
        Self::new()
    }
}

/// Manages the assignment of unique primes to string components.
pub struct PrimeMorphism {
    component_to_prime: HashMap<String, u64>,
}

impl PrimeMorphism {
    pub fn new() -> Self {
        PrimeMorphism {
            component_to_prime: HashMap::new(),
        }
    }

    /// Gets the prime for a given component, assigning a new one if not already present.
    pub fn get_prime_for_component(&mut self, component: &str) -> u64 {
        let mut generator = PRIME_GENERATOR.lock().unwrap();
        *self.component_to_prime.entry(component.to_string()).or_insert_with(|| generator.get_next_prime())
    }

    /// Converts a path (Vec<String>) into a PrimeVector.
    /// The coefficient of each prime is based on its depth in the path (e.g., higher depth, higher coeff).
    pub fn path_to_prime_vector(&mut self, path: &[String]) -> PrimeVector {
        let mut prime_vector = PrimeVector::new();
        // Base prime for "crate"
        prime_vector.map.insert(self.get_prime_for_component("crate_root"), 1); // special prime for root

        for (depth, component) in path.iter().enumerate() {
            let prime = self.get_prime_for_component(component);
            // Coefficient based on depth, or some other metric
            // For simplicity, let's use depth + 1 as the coefficient
            *prime_vector.map.entry(prime).or_insert(0) += (depth + 1) as u64;
        }
        prime_vector
    }
}
