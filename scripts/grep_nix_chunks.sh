#!/usr/bin/env bash

# Default paths
DEFAULT_NIX_CHUNKS_FILE="/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/index/chunks/nix.txt"
DEFAULT_TERMS_FILE="/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/index/terms.txt"
DEFAULT_OUTPUT_BASE_PATH="/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/index/cache/nix-nix"

# Assign parameters or use defaults
NIX_CHUNKS_FILE="${1:-$DEFAULT_NIX_CHUNKS_FILE}"
TERMS_FILE="${2:-$DEFAULT_TERMS_FILE}"
OUTPUT_BASE_PATH="${3:-$DEFAULT_OUTPUT_BASE_PATH}"

# Check if the nix chunks file exists
if [ ! -f "$NIX_CHUNKS_FILE" ]; then
  echo "Error: Nix chunks file not found at $NIX_CHUNKS_FILE"
  exit 1
fi

# Check if the terms file exists
if [ ! -f "$TERMS_FILE" ]; then
  echo "Error: Terms file not found at $TERMS_FILE"
  exit 1
fi

# Create the output directory if it doesn't exist
mkdir -p "$(dirname "$OUTPUT_BASE_PATH")"

echo "Starting grep operation for each term from $TERMS_FILE on files listed in $NIX_CHUNKS_FILE..."

# Read each term from TERMS_FILE
while IFS= read -r term;
do
  if [[ -z "$term" ]]; then
    continue # Skip empty lines
  fi

  # Sanitize term for use in filename (replace non-alphanumeric with underscore)
  SANITIZED_TERM=${term//[^a-zA-Z0-9]/_}
  TERM_OUTPUT_FILE="${OUTPUT_BASE_PATH}_${SANITIZED_TERM}.txt"

  echo "Processing term: \"$term\" (results to $TERM_OUTPUT_FILE)"
  # Clear the term-specific output file before writing
  echo -n > "$TERM_OUTPUT_FILE"

  # Read each file path from NIX_CHUNKS_FILE and run grep -i
  while IFS= read -r file_path;
  do
    if [ -f "$file_path" ]; then
      GREP_OUTPUT=$(grep -i "$term" "$file_path")
      if [[ -n "$GREP_OUTPUT" ]]; then
        echo "Match found in: $file_path" >> "$TERM_OUTPUT_FILE"
        echo "$GREP_OUTPUT" >> "$TERM_OUTPUT_FILE"
      fi
    else
      echo "Warning: File not found, skipping: $file_path" >> "$TERM_OUTPUT_FILE"
    fi
  done < "$NIX_CHUNKS_FILE"

  echo "Finished processing term: \"$term\". Results saved to $TERM_OUTPUT_FILE"

done < "$TERMS_FILE"

echo "Grep operation completed for all terms."
