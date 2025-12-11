#[derive(Debug, Clone, PartialEq, serde::Serialize, serde::Deserialize)]
pub struct Triple {
    pub subject: String,
    pub predicate: String,
    pub object: String,
}
