use std::collections::HashMap;

pub struct CharacterSequenceAnalyzer {
    pub pair_transitions: HashMap<(char, char), usize>,
    pub ngrams: HashMap<usize, HashMap<String, usize>>,
}

impl CharacterSequenceAnalyzer {
    pub fn new() -> Self {
        let mut ngrams_map = HashMap::new();
        ngrams_map.insert(3, HashMap::new());
        ngrams_map.insert(5, HashMap::new());
        ngrams_map.insert(7, HashMap::new());
        ngrams_map.insert(11, HashMap::new());

        CharacterSequenceAnalyzer {
            pair_transitions: HashMap::new(),
            ngrams: ngrams_map,
        }
    }

    pub fn collect_from_identifiers(&mut self, identifiers: &[String]) {
        for ident in identifiers {
            self.collect_pair_transitions_from_identifier(ident);

            let mut substrings = Vec::new();
            let mut current_word = String::new();
            let mut last_char_was_upper = false;

            for c in ident.chars() {
                if c == '_' || c == '-' || c == '<' || c == '>' || c == ' ' {
                    if !current_word.is_empty() {
                        substrings.push(current_word.clone());
                        current_word.clear();
                    }
                    last_char_was_upper = false;
                } else if c.is_uppercase() {
                    if !last_char_was_upper && !current_word.is_empty() {
                        substrings.push(current_word.clone());
                        current_word.clear();
                    }
                    current_word.push(c);
                    last_char_was_upper = true;
                } else { // is_lowercase or is_numeric
                    if last_char_was_upper && current_word.len() > 1 {
                        let last_char = current_word.pop().unwrap();
                        substrings.push(current_word.clone());
                        current_word.clear();
                        current_word.push(last_char);
                    }
                    current_word.push(c);
                    last_char_was_upper = false;
                }
            }
            if !current_word.is_empty() {
                substrings.push(current_word);
            }

            for sub in substrings {
                self.collect_ngrams_from_identifier(&sub.to_lowercase(), &[3, 5, 7, 11]);
            }
        }
    }

    fn collect_pair_transitions_from_identifier(&mut self, s: &str) {
        let chars: Vec<char> = s.chars().collect();
        for i in 0..chars.len().saturating_sub(1) {
            *self.pair_transitions.entry((chars[i], chars[i+1])).or_insert(0) += 1;
        }
    }

    fn collect_ngrams_from_identifier(&mut self, s: &str, n_values: &[usize]) {
        for &n in n_values {
            if s.len() >= n {
                for i in 0..=s.len() - n {
                    let ngram = &s[i..i+n];
                    *self.ngrams.get_mut(&n).unwrap().entry(ngram.to_string()).or_insert(0) += 1;
                }
            }
        }
    }
}