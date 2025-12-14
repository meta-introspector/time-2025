use sled::Db;
use crate::db_trait::CacheDB;

pub struct SledCache<'a> {
    db: &'a Db,
}

impl<'a> SledCache<'a> {
    pub fn new(db: &'a Db) -> Self {
        Self { db }
    }
}

impl<'a> CacheDB for SledCache<'a> {
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
