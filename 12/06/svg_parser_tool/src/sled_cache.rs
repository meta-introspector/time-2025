use sled::Db;
use crate::db_trait::CacheDB;
use std::path::Path;

pub struct SledCache {
    db: Db,
}

impl SledCache {
    pub fn new(path: &Path) -> Result<Self, sled::Error> {
        let db = sled::open(path)?;
        Ok(Self { db })
    }
}

impl CacheDB for SledCache {
    fn get(&self, key: &str) -> Result<Option<Vec<u8>>, Box<dyn std::error::Error>> {
        match self.db.get(key)? {
            Some(value) => Ok(Some(value.to_vec())),
            None => Ok(None),
        }
    }

    fn put(&self, key: &str, value: &[u8]) -> Result<(), Box<dyn std::error::Error>> {
        self.db.insert(key, value)?;
        self.db.flush()?;
        Ok(())
    }
}
