use redb::{Database, ReadableTable, TableDefinition};
use crate::db_trait::CacheDB;

pub const TABLE: TableDefinition<&str, &[u8]> = TableDefinition::new("cache");

pub struct RedbCache<'a> {
    db: &'a Database,
}

impl<'a> RedbCache<'a> {
    pub fn new(db: &'a Database) -> Self {
        Self { db }
    }
}

impl<'a> CacheDB for RedbCache<'a> {
    fn get(&self, key: &str) -> Result<Option<Vec<u8>>, Box<dyn std::error::Error>> {
        let read_txn = self.db.begin_read()?;
        let table = read_txn.open_table(TABLE)?;
        match table.get(key)? {
            Some(value) => Ok(Some(value.value().to_vec())),
            None => Ok(None),
        }
    }

    fn put(&self, key: &str, value: &[u8]) -> Result<(), Box<dyn std::error::Error>> {
        let write_txn = self.db.begin_write()?;
        {
            let mut table = write_txn.open_table(TABLE)?;
            table.insert(key, value)?;
        }
        write_txn.commit()?;
        Ok(())
    }
}
