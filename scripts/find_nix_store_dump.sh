#!/usr/bin/env bash
set -euo pipefail
set -x # Enable shell debugging

# Assign parameters
NIX_CHUNKS_FILE="$1"
TERMS_FILE="$2"
OUTPUT_BASE_PATH="$3"

# Validate parameters
if [[ -z "$NIX_CHUNKS_FILE" ]]; then
  echo "Error: NIX_CHUNKS_FILE is not provided." >&2
  exit 1
fi
if [[ -z "$TERMS_FILE" ]]; then
  echo "Error: TERMS_FILE is not provided." >&2
  exit 1
fi
if [[ -z "$OUTPUT_BASE_PATH" ]]; then
  echo "Error: OUTPUT_BASE_PATH is not provided." >&2
  exit 1
fi

# Check if the nix chunks file exists
if [ ! -f "$NIX_CHUNKS_FILE" ]; then
  echo "Error: Nix chunks file not found at $NIX_CHUNKS_FILE" >&2
  exit 1
fi

# Check if the terms file exists
if [ ! -f "$TERMS_FILE" ]; then
  echo "Error: Terms file not found at $TERMS_FILE" >&2
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

  echo "DEBUG: Processing raw term: $term"
  # Sanitize term for use in filename (replace non-alphanumeric with underscore)
  # SC2001 fix: Use shell parameter expansion instead of sed
  SANITIZED_TERM=${term//[^a-zA-Z0-9]/_}
  TERM_OUTPUT_FILE="${OUTPUT_BASE_PATH}_${SANITIZED_TERM}.txt"

  echo "DEBUG: Sanitized term: $SANITIZED_TERM"
  echo "DEBUG: Term output file: $TERM_OUTPUT_FILE"

  echo "Processing term: \"$term\" (results to $TERM_OUTPUT_FILE)"
  # Clear the term-specific output file before writing
  # SC2188 fix: Use true > instead of just >
  true > "$TERM_OUTPUT_FILE"
  echo "DEBUG: Cleared file: $TERM_OUTPUT_FILE"

  # Read each file path from NIX_CHUNKS_FILE and run grep -i
  while IFS= read -r file_path;
  do
    if [ -f "$file_path" ]; then
      echo "DEBUG: Grepping in file: $file_path"
      GREP_OUTPUT=$(grep -i "$term" "$file_path" || true) # Add || true to prevent pipefail from exiting on no match
      if [[ -n "$GREP_OUTPUT" ]]; then
        echo "DEBUG: Match found in $file_path. Appending to $TERM_OUTPUT_FILE"
        echo "Match found in: $file_path" >> "$TERM_OUTPUT_FILE"
        echo "$GREP_OUTPUT" >> "$TERM_OUTPUT_FILE"
      else
        echo "DEBUG: No match found in $file_path"
      fi
    else
      echo "Warning: File not found, skipping: $file_path" >> "$TERM_OUTPUT_FILE"
    fi
  done < "$NIX_CHUNKS_FILE"

  echo "Finished processing term: \"$term\". Results saved to $TERM_OUTPUT_FILE"

done < "$TERMS_FILE"

echo "Grep operation completed for all terms."