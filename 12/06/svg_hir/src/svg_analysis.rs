use std::collections::HashMap;
use crate::{
    Svg, SvgElementEnum, Path,
    Style, Transform,
};
use crate::prime_vector::{PrimeMorphism, PrimeVector, PrimeGenerator};
use crate::keys;
use crate::traits::svg_component::SvgComponent;
use crate::traits::has_embedded_primes::HasEmbeddedPrimes; // For string literal analysis


pub struct SvgAnalysisReport {
    pub symbol_table: HashMap<String, PrimeVector>, // Maps full path of SVG element to its PrimeVector
    pub prime_occurrences: HashMap<u64, Vec<String>>, // Prime resonances based on lengths/values
    pub prime_factor_occurrences: HashMap<u64, Vec<String>>, // Prime factors of numeric properties
}

pub struct SvgVisitor<'a> {
    pub prime_morphism: PrimeMorphism,
    pub symbol_table: HashMap<String, PrimeVector>,
    pub prime_occurrences: HashMap<u64, Vec<String>>,
    pub prime_factor_occurrences: HashMap<u64, Vec<String>>,
    pub primes_to_analyze: &'a [u64], // Configurable list of primes for resonance checks
    current_path: Vec<String>, // Tracks the current path for nested elements
}

impl<'a> SvgVisitor<'a> {
    pub fn new(primes_to_analyze: &'a [u64]) -> Self {
        let _char_freq_analyzer = CharFrequencyAnalyzer::new();
        // For now, let's just initialize with a default empty char_to_prime_map, or a fixed one.
        // A better approach would be to collect all text content from SVGs first to build this map.
        let char_to_prime_map = HashMap::new(); // Placeholder
        let prime_morphism = PrimeMorphism::new(char_to_prime_map);

        SvgVisitor {
            prime_morphism,
            symbol_table: HashMap::new(),
            prime_occurrences: HashMap::new(),
            prime_factor_occurrences: HashMap::new(),
            primes_to_analyze,
            current_path: Vec::new(),
        }
    }

    pub fn visit_svg(&mut self, svg: &Svg) {
        self.current_path.push("svg".to_string());
        self.current_path.push(svg.id.clone().unwrap_or_else(|| "svg_root".to_string()));

        let mut prime_vector = self.prime_morphism.path_to_prime_vector(&self.current_path);
        prime_vector.map.insert(self.prime_morphism.get_prime_for_component(keys::PREDICATE_IS_SVG), 1);
        
        if svg.id.is_some() {
            prime_vector.map.insert(self.prime_morphism.get_prime_for_component(keys::PREDICATE_HAS_ID), 1);
            self.analyze_string_property(&svg.id.as_ref().unwrap(), "id", self.current_path.clone(), &mut prime_vector);
        }
        self.analyze_numeric_property(svg.children.len() as u64, keys::PREDICATE_CHILD_COUNT, self.current_path.clone(), &mut prime_vector);
        self.analyze_numeric_property(svg.bounding_box().width as u64, keys::PREDICATE_WIDTH, self.current_path.clone(), &mut prime_vector);
        self.analyze_numeric_property(svg.bounding_box().height as u64, keys::PREDICATE_HEIGHT, self.current_path.clone(), &mut prime_vector);
        self.analyze_numeric_property(svg.bounding_box().area() as u64, keys::PREDICATE_AREA, self.current_path.clone(), &mut prime_vector);
        if svg.view_box.is_some() {
            prime_vector.map.insert(self.prime_morphism.get_prime_for_component(keys::PREDICATE_VIEW_BOX), 1);
        }

        self.symbol_table.insert(self.current_path.join("::"), prime_vector);

        for child in &svg.children {
            self.visit_element(child);
        }
        self.current_path.pop();
        self.current_path.pop();
    }

    fn visit_element(&mut self, element: &SvgElementEnum) {
        
        match element {
            SvgElementEnum::Rect(r) => {
                self.current_path.push(format!("rect::{}", r.id.clone().unwrap_or_else(|| "anon_rect".to_string())));
                let mut prime_vector = self.prime_morphism.path_to_prime_vector(&self.current_path);
                prime_vector.map.insert(self.prime_morphism.get_prime_for_component(keys::PREDICATE_IS_RECT), 1);
                self.analyze_common_element_properties(r.id.as_ref(), r.style.as_ref(), r.transform.as_ref(), self.current_path.clone(), &mut prime_vector);
                self.analyze_numeric_property(r.width as u64, keys::PREDICATE_WIDTH, self.current_path.clone(), &mut prime_vector);
                self.analyze_numeric_property(r.height as u64, keys::PREDICATE_HEIGHT, self.current_path.clone(), &mut prime_vector);
                self.analyze_numeric_property(r.bounding_box().area() as u64, keys::PREDICATE_AREA, self.current_path.clone(), &mut prime_vector);
                self.symbol_table.insert(self.current_path.join("::"), prime_vector);
            },
            SvgElementEnum::Circle(c) => {
                self.current_path.push(format!("circle::{}", c.id.clone().unwrap_or_else(|| "anon_circle".to_string())));
                let mut prime_vector = self.prime_morphism.path_to_prime_vector(&self.current_path);
                prime_vector.map.insert(self.prime_morphism.get_prime_for_component(keys::PREDICATE_IS_CIRCLE), 1);
                self.analyze_common_element_properties(c.id.as_ref(), c.style.as_ref(), c.transform.as_ref(), self.current_path.clone(), &mut prime_vector);
                self.analyze_numeric_property(c.r as u64, "predicate::radius", self.current_path.clone(), &mut prime_vector);
                self.analyze_numeric_property(c.bounding_box().area() as u64, keys::PREDICATE_AREA, self.current_path.clone(), &mut prime_vector);
                self.symbol_table.insert(self.current_path.join("::"), prime_vector);
            },
            SvgElementEnum::Ellipse(e) => {
                self.current_path.push(format!("ellipse::{}", e.id.clone().unwrap_or_else(|| "anon_ellipse".to_string())));
                let mut prime_vector = self.prime_morphism.path_to_prime_vector(&self.current_path);
                prime_vector.map.insert(self.prime_morphism.get_prime_for_component(keys::PREDICATE_IS_ELLIPSE), 1);
                self.analyze_common_element_properties(e.id.as_ref(), e.style.as_ref(), e.transform.as_ref(), self.current_path.clone(), &mut prime_vector);
                self.analyze_numeric_property(e.rx as u64, "predicate::radius_x", self.current_path.clone(), &mut prime_vector);
                self.analyze_numeric_property(e.ry as u64, "predicate::radius_y", self.current_path.clone(), &mut prime_vector);
                self.analyze_numeric_property(e.bounding_box().area() as u64, keys::PREDICATE_AREA, self.current_path.clone(), &mut prime_vector);
                self.symbol_table.insert(self.current_path.join("::"), prime_vector);
            },
            SvgElementEnum::Text(t) => {
                self.current_path.push(format!("text::{}", t.id.clone().unwrap_or_else(|| "anon_text".to_string())));
                let mut prime_vector = self.prime_morphism.path_to_prime_vector(&self.current_path);
                prime_vector.map.insert(self.prime_morphism.get_prime_for_component(keys::PREDICATE_IS_TEXT), 1);
                self.analyze_common_element_properties(t.id.as_ref(), t.style.as_ref(), t.transform.as_ref(), self.current_path.clone(), &mut prime_vector);
                self.analyze_string_property(&t.content, keys::PREDICATE_TEXT_CONTENT_LENGTH, self.current_path.clone(), &mut prime_vector);
                self.analyze_numeric_property(t.word_count as u64, keys::PREDICATE_TEXT_WORD_COUNT, self.current_path.clone(), &mut prime_vector);
                self.symbol_table.insert(self.current_path.join("::"), prime_vector);
            },
            SvgElementEnum::Path(p) => {
                self.current_path.push(format!("path::{}", p.id.clone().unwrap_or_else(|| "anon_path".to_string())));
                let mut prime_vector = self.prime_morphism.path_to_prime_vector(&self.current_path);
                prime_vector.map.insert(self.prime_morphism.get_prime_for_component(keys::PREDICATE_IS_PATH), 1);
                self.analyze_common_element_properties(p.id.as_ref(), p.style.as_ref(), p.transform.as_ref(), self.current_path.clone(), &mut prime_vector);
                self.analyze_string_property(&p.d, keys::PREDICATE_PATH_DATA_LENGTH, self.current_path.clone(), &mut prime_vector);
                self.symbol_table.insert(self.current_path.join("::"), prime_vector);
            },
            SvgElementEnum::Group(g) => {
                self.current_path.push(format!("group::{}", g.id.clone().unwrap_or_else(|| "anon_group".to_string())));
                let mut prime_vector = self.prime_morphism.path_to_prime_vector(&self.current_path);
                prime_vector.map.insert(self.prime_morphism.get_prime_for_component(keys::PREDICATE_IS_GROUP), 1);
                self.analyze_common_element_properties(g.id.as_ref(), g.style.as_ref(), g.transform.as_ref(), self.current_path.clone(), &mut prime_vector);
                self.analyze_numeric_property(g.children.len() as u64, keys::PREDICATE_CHILD_COUNT, self.current_path.clone(), &mut prime_vector);
                self.analyze_numeric_property(g.bounding_box().area() as u64, keys::PREDICATE_AREA, self.current_path.clone(), &mut prime_vector);
                self.symbol_table.insert(self.current_path.join("::"), prime_vector);
                for child in &g.children {
                    self.visit_element(child);
                }
            },
        }
        self.current_path.pop();
    }

    fn analyze_common_element_properties(&mut self, id: Option<&String>, style: Option<&Style>, transform: Option<&Transform>, current_path: Vec<String>, prime_vector: &mut PrimeVector) {
        if id.is_some() {
            prime_vector.map.insert(self.prime_morphism.get_prime_for_component(keys::PREDICATE_HAS_ID), 1);
            self.analyze_string_property(id.as_ref().unwrap(), "id", current_path, prime_vector);
        }
        if let Some(s) = style {
            if s.fill.is_some() { prime_vector.map.insert(self.prime_morphism.get_prime_for_component(keys::PREDICATE_HAS_FILL), 1); }
            if s.stroke.is_some() { prime_vector.map.insert(self.prime_morphism.get_prime_for_component(keys::PREDICATE_HAS_STROKE), 1); }
        }
        if transform.is_some() {
            prime_vector.map.insert(self.prime_morphism.get_prime_for_component(keys::PREDICATE_HAS_TRANSFORM), 1);
        }
    }

    fn analyze_string_property(&mut self, s: &String, property_name: &str, current_path: Vec<String>, prime_vector: &mut PrimeVector) {
        let len = s.len() as u64;
        
        // Add predicate for length
        prime_vector.map.insert(self.prime_morphism.get_prime_for_component(&format!("predicate::{}_length", property_name)), len);

        // Check for prime resonance in length
        if self.primes_to_analyze.contains(&len) {
            self.prime_occurrences.entry(len).or_default().push(format!(
                "Property '{}' string '{}' has prime length {}. Path: {}",
                property_name, s, len, current_path.join("::")
            ));
            prime_vector.map.insert(self.prime_morphism.get_prime_for_component(keys::PREDICATE_PRIME_RESONANCE), 1);
        }

        // Check for embedded primes in the string literal
        for (prime, desc) in s.as_str().find_embedded_primes(self.primes_to_analyze) {
            if prime == 0 { // Placeholder for large primes
                self.prime_occurrences.entry(0).or_default().push(format!("Property '{}': {}. Path: {}", property_name, desc, current_path.join("::")));
            } else {
                self.prime_occurrences.entry(prime).or_default().push(format!("Property '{}': {}. Path: {}", property_name, desc, current_path.join("::")));
            }
            prime_vector.map.insert(self.prime_morphism.get_prime_for_component(keys::PREDICATE_PRIME_RESONANCE), 1);
        }

        // Prime factorization of ASCII sum
        let ascii_sum: u64 = s.bytes().map(|b| b as u64).sum();
        if ascii_sum > 1 {
            for (factor, exponent) in PrimeFactorizer::get_prime_factors(ascii_sum) {
                self.prime_factor_occurrences
                    .entry(factor)
                    .or_default()
                    .push(format!(
                        "Property '{}' string '{}' (ASCII sum {}) has prime factor {} with exponent {}. Path: {}",
                        property_name, s, ascii_sum, factor, exponent, current_path.join("::")
                    ));
            }
        }
    }

    fn analyze_numeric_property(&mut self, num: u64, property_name: &str, current_path: Vec<String>, prime_vector: &mut PrimeVector) {
        // Add predicate for numeric value
        prime_vector.map.insert(self.prime_morphism.get_prime_for_component(property_name), num);

        if self.primes_to_analyze.contains(&num) {
            self.prime_occurrences.entry(num).or_default().push(format!(
                "Property '{}' has prime value {}. Path: {}",
                property_name, num, current_path.join("::")
            ));
            prime_vector.map.insert(self.prime_morphism.get_prime_for_component(keys::PREDICATE_PRIME_RESONANCE), 1);
        }

        if num > 1 {
            for (factor, exponent) in PrimeFactorizer::get_prime_factors(num) {
                self.prime_factor_occurrences
                    .entry(factor)
                    .or_default()
                    .push(format!(
                        "Property '{}' with value {} has prime factor {} with exponent {}. Path: {}",
                        property_name, num, factor, exponent, current_path.join("::")
                    ));
            }
        }
    }
}

// TODO: Need a CharFrequencyAnalyzer for SVG strings
// Placeholder CharFrequencyAnalyzer (copied from monster_svg_morphism for now)
pub struct CharFrequencyAnalyzer {
    char_frequencies: HashMap<char, usize>,
}

impl CharFrequencyAnalyzer {
    pub fn new() -> Self {
        CharFrequencyAnalyzer {
            char_frequencies: HashMap::new(),
        }
    }

    // This method needs to be adapted to collect characters from SVG text content and attribute values
    pub fn collect_char_frequencies(&mut self, _root_path: &Path) {
        // Placeholder implementation
        // In a real scenario, this would iterate through all SVG files,
        // parse them, and collect characters from Text elements and relevant attributes.
        // For now, let's assume some common characters or an empty map.
    }

    pub fn generate_char_to_prime_map(self) -> HashMap<char, u64> {
        let mut sorted_chars: Vec<(char, usize)> = self.char_frequencies.into_iter().collect();
        sorted_chars.sort_by(|a, b| b.1.cmp(&a.1).then_with(|| a.0.cmp(&b.0)));

        let mut char_to_prime = HashMap::new();
        let mut prime_generator = PrimeGenerator::new();
        
        for (ch, _freq) in sorted_chars {
            char_to_prime.insert(ch, prime_generator.get_next_prime());
        }
        char_to_prime
    }
}

struct PrimeFactorizer;

impl PrimeFactorizer {
    fn get_prime_factors(n: u64) -> HashMap<u64, u32> {
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
