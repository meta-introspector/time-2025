# Database Abstraction

This document outlines the current database abstraction layer implemented in `svg_parser_tool`. The primary goal of this abstraction is to allow for flexible swapping of underlying database technologies, particularly for caching mechanisms, without significant code changes in the application logic.

## Motivation

Initially, `svg_parser_tool` utilized `rocksdb` for caching analysis results. To enhance flexibility, enable experimentation with different database characteristics (e.g., performance, footprint), and prepare for future integration with more structured data models (like those described as "buddies of the same homotopy, prime factors, exponents, etc." which might involve ORMs), a trait-based abstraction layer was introduced.

## `CacheDB` Trait

The core of the caching abstraction is the `CacheDB` trait, defined in `svg_parser_tool/src/db_trait.rs`:

```rust
pub trait CacheDB {
    fn get(&self, key: &str) -> Result<Option<Vec<u8>>, Box<dyn std::error::Error>>;
    fn put(&self, key: &str, value: &[u8]) -> Result<(), Box<dyn std::error::Error>>;
}
```

This trait defines a minimal interface for a key-value store, supporting basic `get` and `put` operations.

## Implemented Backends

The `CacheDB` trait has been implemented for the following embedded key-value databases:

1.  **`RocksDBCache`**: A wrapper around the `rocksdb::DB` instance.
    *   **Location**: `svg_parser_tool/src/rocksdb_cache.rs`
    *   **Features**: Provides robust, persistent key-value storage.

2.  **`RedbCache`**: A wrapper around the `redb::Database` instance.
    *   **Location**: `svg_parser_tool/src/redb_cache.rs`
    *   **Features**: A high-performance, ACID-compliant, copy-on-write embedded database.

3.  **`SledCache`**: A wrapper around the `sled::Db` instance.
    *   **Location**: `svg_parser_tool/src/sled_cache.rs`
    *   **Features**: A modern, embedded database that offers a `B-tree` based key-value store.

## Usage in `svg_parser_tool`

The `svg_parser_tool`'s processing logic (e.g., `svg_processor.rs`, `rust_processor.rs`, `file_collector.rs`) now accepts a `&dyn CacheDB` trait object. This allows the application logic to remain decoupled from the specific database implementation.

### Binary Integration

The `wordcloud_generator` and `cache_inspector` binaries have been updated to include a `--db-type` command-line argument. Users can specify `'rocksdb'`, `'redb'`, or `'sled'` to select the desired caching backend.

*   **`wordcloud_generator`**: Uses the selected backend to cache processed file analysis (`ExtractedData`) and aggregated reports.
*   **`cache_inspector`**: Provides utilities to inspect keys and values within the selected cache backend.

### Example: Selecting `redb`

To run `wordcloud_generator` using the `redb` backend:

```bash
cargo run --bin wordcloud_generator -- --db-type redb [PATH_TO_FILES]
```

## Future Work

The user has indicated future plans to:
*   Extract more complex data from SVG files.
*   Classify these objects into tables within a more structured schema.
*   Utilize an Object-Relational Mapper (ORM), such as `sea-orm`, for managing these structured relationships.
*   Consider integration with browser-specific storage (local storage, remote storage) and decentralized technologies (IPFS, libp2p).

The current `CacheDB` abstraction serves as a foundational step towards these broader database and data modeling goals.
