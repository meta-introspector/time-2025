pub trait CacheDB {
    fn get(&self, key: &str) -> Result<Option<Vec<u8>>, Box<dyn std::error::Error>>;
    fn put(&self, key: &str, value: &[u8]) -> Result<(), Box<dyn std::error::Error>>;
}
