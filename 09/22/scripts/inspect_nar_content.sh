#!/usr/bin/env bash

set -euo pipefail

NAR_FILE_PATH="$1"
TEMP_EXTRACT_DIR="/tmp/nar_extracted_content_$(date +%s)"

cleanup() {
  echo "Cleaning up extracted NAR content..."
  rm -rf "$TEMP_EXTRACT_DIR"
}

trap cleanup EXIT

if [ -z "$NAR_FILE_PATH" ]; then
  echo "Error: Usage: $0 <absolute_path_to_nar_file>"
  exit 1
fi

if [ ! -f "$NAR_FILE_PATH" ]; then
  echo "Error: NAR file not found: $NAR_FILE_PATH"
  exit 1
fi

mkdir -p "$TEMP_EXTRACT_DIR"

echo "Extracting NAR content to: $TEMP_EXTRACT_DIR"
# Assuming NAR is essentially a tar archive
tar -xf "$NAR_FILE_PATH" -C "$TEMP_EXTRACT_DIR"

echo "--- Keyword Frequency Analysis of NAR Content ---"
# Extract strings from all files, convert to lowercase, remove punctuation, split into words, count frequency
find "$TEMP_EXTRACT_DIR" -type f -print0 | xargs -0 strings | \
  tr '[:upper:]' '[:lower:]' | \
  sed 's/[[:punct:]]//g' | \
  grep -o -E '\w+' | \
  sort | uniq -c | sort -nr | head -n 20

echo "--- End of Keyword Frequency Analysis ---"

echo "NAR content inspection complete."

