#!/usr/bin/env bash

set -euo pipefail

# This is a dummy script for generating OEIS index.
# In a real implementation, this script would:
# 1. Scan project index files (Markdown and Rust) for OEIS references.
# 2. Extract OEIS sequence IDs.
# 3. Generate an index (e.g., JSON) of these references.

echo "Generating OEIS index (dummy output)..."
out="$1"
mkdir -p "$out"
echo '{"oeis_references": ["A000001", "A000002"]}' > "$out"/oeis_index.json
