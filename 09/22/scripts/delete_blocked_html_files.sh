#!/usr/bin/env bash

set -euo pipefail

CACHE_DIR="/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/22/wikipedia_cache"
ERROR_PATTERN="Please set a proper user-agent and respect our robot policy"

for file in "$CACHE_DIR"/*.html; do
  if grep -q "$ERROR_PATTERN" "$file"; then
    echo "Deleting blocked file: $file"
    rm "$file"
  fi
done

echo "Deleted HTML files containing the blocked content pattern from $CACHE_DIR."
