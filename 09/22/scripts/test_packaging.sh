#!/usr/bin/env bash

set -euo pipefail

if [ -z "$1" ]; then
  echo "Usage: $0 <article_name>"
  exit 1
fi

ARTICLE_NAME="$1"
OUTPUT_DIR="./test_output/$ARTICLE_NAME"

echo "Creating output directory..."
mkdir -p "$OUTPUT_DIR"

echo "Copying article to output directory..."
cp "/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/22/wikipedia_cache/$ARTICLE_NAME" "$OUTPUT_DIR/"

echo "Listing contents of output directory..."
ls -l "$OUTPUT_DIR"
