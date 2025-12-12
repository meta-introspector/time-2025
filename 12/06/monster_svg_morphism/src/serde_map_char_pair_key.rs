use serde::{de, Deserializer, Serializer, Serialize, Deserialize};
use std::collections::HashMap;

// Custom serialization for HashMap<(char, char), T> to a JSON array of [key_string, value] pairs.
pub fn serialize<S, V>(map: &HashMap<(char, char), V>, serializer: S) -> Result<S::Ok, S::Error>
where
    S: Serializer,
    V: Serialize,
{
    serializer.collect_seq(map.iter().map(|((k1, k2), v)| (format!("{}{}", k1, k2), v)))
}

// Custom deserialization for HashMap<(char, char), T> from a JSON array of [key_string, value] pairs.
pub fn deserialize<'de, D, V>(deserializer: D) -> Result<HashMap<(char, char), V>, D::Error>
where
    D: Deserializer<'de>,
    V: Deserialize<'de>,
{
    let vec = Vec::<(String, V)>::deserialize(deserializer)?;
    let mut map = HashMap::with_capacity(vec.len());
    for (key_str, value) in vec {
        if key_str.len() != 2 {
            return Err(de::Error::custom("Expected a two-character string for char pair key"));
        }
        let mut chars = key_str.chars();
        let k1 = chars.next().unwrap();
        let k2 = chars.next().unwrap();
        map.insert((k1, k2), value);
    }
    Ok(map)
}