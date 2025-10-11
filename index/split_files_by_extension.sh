#!/usr/bin/env bash
# This script splits files.txt into chunks based on unique file extensions.

echo "Creating directory for file chunks..."
mkdir -p "chunks"

echo "Splitting files.txt by extension..."
while IFS= read -r extension; do
  if [[ -n "$extension" ]]; then # Ensure extension is not empty
    echo "Processing extension: $extension"
    grep -E "\.$extension$" "files.txt" > "chunks/$extension.txt"
  fi
done < "extensions.txt"

# Additionally, grep for files containing 'makefile' in their name (case-insensitive)
grep -i "makefile" "files.txt" > "chunks/makefile.txt"

echo "File splitting complete. Chunks are in index/chunks/."