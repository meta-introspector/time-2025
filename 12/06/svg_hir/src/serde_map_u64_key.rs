use serde::{de, Deserializer, Serializer, Serialize, Deserialize};
use std::collections::HashMap;
use std::fmt::Display;
use std::str::FromStr;

// Custom serialization for HashMap<u64, T> to a JSON array of [key, value] pairs.
pub fn serialize<S, K, V>(map: &HashMap<K, V>, serializer: S) -> Result<S::Ok, S::Error>
where
    S: Serializer,
    K: Display + Eq + std::hash::Hash,
    V: Serialize,
{
    serializer.collect_seq(map.iter().map(|(k, v)| (k.to_string(), v)))
}

// Custom deserialization for HashMap<u64, T> from a JSON array of [key, value] pairs.
pub fn deserialize<'de, D, K, V>(deserializer: D) -> Result<HashMap<K, V>, D::Error>
where
    D: Deserializer<'de>,
    K: FromStr + Eq + std::hash::Hash,
    K::Err: Display,
    V: Deserialize<'de>,
{
    let vec = Vec::<(String, V)>::deserialize(deserializer)?;
    let mut map = HashMap::with_capacity(vec.len());
    for (key_str, value) in vec {
        let key = K::from_str(&key_str).map_err(de::Error::custom)?;
        map.insert(key, value);
    }
    Ok(map)
}