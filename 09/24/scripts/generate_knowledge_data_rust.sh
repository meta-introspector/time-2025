#!/usr/bin/env bash

set -euo pipefail

echo "Building Rust knowledge extractor..."
(cd rust_knowledge_extractor && cargo build --release)

echo "Generating knowledge_data.jsonl using Rust extractor..."
./scripts/discover_project_urls.sh | ./rust_knowledge_extractor/target/release/rust_knowledge_extractor > knowledge_data.jsonl

echo "knowledge_data.jsonl generated successfully using Rust."
