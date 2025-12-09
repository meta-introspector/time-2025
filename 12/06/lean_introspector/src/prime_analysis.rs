// lean_introspector/src/prime_analysis.rs
use std::collections::HashMap;

#[derive(Debug, Clone, PartialEq)]
pub struct PrimeVector {
    pub map: HashMap<u64, u64>, // Prime -> Exponent
}

impl PrimeVector {
    pub fn new() -> Self {
        PrimeVector {
            map: HashMap::new(),
        }
    }

    pub fn multiply(&mut self, other: &PrimeVector) {
        for (prime, exponent) in &other.map {
            *self.map.entry(*prime).or_insert(0) += *exponent;
        }
    }
}

pub struct PrimeGenerator {
    current_prime: u64,
}

impl PrimeGenerator {
    pub fn new() -> Self {
        PrimeGenerator { current_prime: 1 } // Start search from 2
    }

    fn is_prime(n: u64) -> bool {
        if n <= 1 {
            return false;
        }
        for i in 2..=(n as f64).sqrt() as u64 {
            if n % i == 0 {
                return false;
            }
        }
        true
    }

    pub fn get_next_prime(&mut self) -> u64 {
        loop {
            self.current_prime += 1;
            if Self::is_prime(self.current_prime) {
                return self.current_prime;
            }
        }
    }
}

pub struct PrimeMorphism {
    char_to_prime: HashMap<char, u64>,
    prime_generator: PrimeGenerator, // PrimeGenerator is now part of PrimeMorphism
    next_predicate_prime: u64,
}

impl PrimeMorphism {
    pub fn new(char_to_prime_map: HashMap<char, u64>) -> Self {
        let mut pg = PrimeGenerator::new();
        let max_prime_in_map = *char_to_prime_map.values().max().unwrap_or(&0);
        pg.current_prime = max_prime_in_map;

        let predicate_start_prime = pg.current_prime; // Store the value before move

        PrimeMorphism {
            char_to_prime: char_to_prime_map,
            prime_generator: pg, // `pg` is moved here
            next_predicate_prime: PrimeGenerator::new_from(predicate_start_prime).get_next_prime(), // Use the stored value
        }
    }

    pub fn get_prime_for_char(&mut self, c: char) -> u64 {
        let pg_ref = &mut self.prime_generator; // Borrow PrimeGenerator
        *self.char_to_prime.entry(c).or_insert_with(|| pg_ref.get_next_prime())
    }

    pub fn get_prime_for_component(&mut self, _component: &str) -> u64 {
        // This is a simplified version. In the full monster_svg_morphism,
        // this would be more sophisticated. For now, assign a unique prime
        // for each component string.
        // We'll use the existing char_to_prime map to build a prime vector for the component string.
        // And then combine it with a predicate prime.

        // This approach assigns a unique predicate prime for each *new* component string.
        // This is not ideal, as the same component string will get a different prime if
        // the program is run multiple times.
        // TODO: Implement a stable component-to-prime mapping for predicates.

        // For now, let's just use a simple sequential predicate prime.
        let prime = self.next_predicate_prime;
        self.next_predicate_prime = PrimeGenerator::new_from(prime).get_next_prime();
        prime
    }

    pub fn string_to_char_prime_vector(&mut self, s: &str) -> PrimeVector {
        let mut pv = PrimeVector::new();
        for c in s.chars() {
            let prime = self.get_prime_for_char(c);
            *pv.map.entry(prime).or_insert(0) += 1;
        }
        pv
    }

    pub fn path_to_prime_vector(&mut self, path_segments: &[String]) -> PrimeVector {
        let mut pv = PrimeVector::new();
        for segment in path_segments {
            let segment_pv = self.string_to_char_prime_vector(segment);
            pv.multiply(&segment_pv);
        }
        pv
    }
}

impl PrimeGenerator {
    pub fn new_from(start_prime: u64) -> Self {
        PrimeGenerator { current_prime: start_prime }
    }
}
