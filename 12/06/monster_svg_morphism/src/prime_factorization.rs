use std::collections::HashMap;

pub struct PrimeFactorizer;

impl PrimeFactorizer {
    pub fn get_prime_factors(n: u64) -> HashMap<u64, u32> {
        let mut factors = HashMap::new();
        let mut d = 2;
        let mut num = n;

        while d * d <= num {
            while num % d == 0 {
                *factors.entry(d).or_insert(0) += 1;
                num /= d;
            }
            d += 1;
        }
        if num > 1 {
            factors.insert(num, 1);
        }
        factors
    }
}