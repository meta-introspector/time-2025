#[cfg(feature = "rocksdb-backend")]
use rocksdb::DB;
#[cfg(feature = "rocksdb-backend")]
use crate::db_trait::CacheDB;
#[cfg(feature = "rocksdb-backend")]
pub struct RocksDBCache<'a> {
    db: &'a DB,
}
#[cfg(feature = "rocksdb-backend")]
impl<'a> RocksDBCache<'a> {
    pub fn new(db: &'a DB) -> Self {
        Self { db }
    }
}
#[cfg(feature = "rocksdb-backend")]
impl<'a> CacheDB for RocksDBCache<'a> {
    fn get(&self, key: &str) -> Result<Option<Vec<u8>>, Box<dyn std::error::Error>> {
        match self.db.get(key) {
            Ok(Some(value)) => Ok(Some(value.to_vec())),
            Ok(None) => Ok(None),
            Err(e) => Err(Box::new(e)),
        }
    }
    fn put(&self, key: &str, value: &[u8]) -> Result<(), Box<dyn std::error::Error>> {
        self.db.put(key, value).map_err(|e| Box::new(e) as Box<dyn std::error::Error>)
    }
}

