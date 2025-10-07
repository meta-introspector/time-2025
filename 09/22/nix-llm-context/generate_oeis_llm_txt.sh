#!/usr/bin/env bash
#
# Script to generate the "LLM.txt" for a given symbol (OEIS).
# Arguments are now read from positional arguments.

set -euo pipefail

# Parse named arguments
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --symbol) 
      SYMBOL_NAME="$2"
      shift
      ;; 
    --symbol=*) 
      SYMBOL_NAME="${1#*=}"
      ;; 
    --html-file-name) 
      HTML_FILE="$2"
      shift
      ;; 
    --html-file-name=*) 
      HTML_FILE="${1#*=}"
      ;; 
    --keywords-script) 
      KEYWORDS_SCRIPT="$2"
      shift
      ;; 
    --keywords-script=*) 
      KEYWORDS_SCRIPT="${1#*=}"
      ;; 
    --links-file-name) 
      LINKS_FILE="$2"
      shift
      ;; 
    --links-file-name=*) 
      LINKS_FILE="${1#*=}"
      ;; 
    --tutorials-pattern) 
      TUTORIALS_PATTERN="$2"
      shift
      ;; 
    --tutorials-pattern=*) 
      TUTORIALS_PATTERN="${1#*=}"
      ;; 
    --main-project) 
      MAIN_PROJECT="$2"
      shift
      ;; 
    --main-project=*) 
      MAIN_PROJECT="${1#*=}"
      ;; 
    --output-dir) 
      OUTPUT_DIR="$2"
      shift
      ;; 
    --output-dir=*) 
      OUTPUT_DIR="${1#*=}"
      ;; 
    *) 
      echo "Unknown parameter passed: $1" >&2
      exit 1
      ;; 
  esac
  shift
done

# Assign parsed values to original script variables
OUTPUT_FILE_NAME="llm-context-${SYMBOL_NAME// /-}.txt" # Construct output file name
OUTPUT_FILE_PATH="${OUTPUT_DIR}/${OUTPUT_FILE_NAME}"

# Ensure all required variables are set
if [ -z "$SYMBOL_NAME" ] || [ -z "$HTML_FILE" ] || [ -z "$KEYWORDS_SCRIPT" ] || [ -z "$LINKS_FILE" ] || [ -z "$TUTORIALS_PATTERN" ] || [ -z "$OUTPUT_DIR" ] || [ -z "$MAIN_PROJECT" ]; then
  echo "Error: Missing required arguments." >&2
  exit 1
fi

# Create a temporary file to build the content
TEMP_OUTPUT_FILE=$(mktemp)

{
echo "# $SYMBOL_NAME - LLM Context"
echo ""

echo "## Source Information"
echo "- Main Project Path: $MAIN_PROJECT"
echo ""

echo "## Wikipedia Content"
cat "$HTML_FILE"
echo ""

echo "## Extracted Keywords"
"$KEYWORDS_SCRIPT" "$HTML_FILE" 10 | sed 's/^[ ]*[0-9]* //g'
echo ""

echo "## Related Links"
grep -i "${SYMBOL_NAME// /_}" "$LINKS_FILE" || true
echo ""

echo "## Related Tutorials"
# The find command needs to search within the source directory passed as $src
# from the Nix derivation.
# The HTML_FILE variable contains the absolute path to the HTML file within the Nix store.
# We need to find the base source directory from HTML_FILE.
# Example: HTML_FILE = /nix/store/.../wikipedia_cache/Monster_group.html
# Source directory = /nix/store/.../
# So, we need to go up two levels from HTML_FILE to get to the source root.
SOURCE_ROOT=$(dirname "$(dirname "$HTML_FILE")")

# Extract just the filename pattern from TUTORIALS_PATTERN
FILENAME_TUTORIALS_PATTERN=$(basename "$TUTORIALS_PATTERN")

# Only run find if TUTORIALS_PATTERN is not empty
if [ -n "$FILENAME_TUTORIALS_PATTERN" ]; then
  find "$SOURCE_ROOT" -maxdepth 2 -type f -name "$FILENAME_TUTORIALS_PATTERN" -printf "- %P\n"
fi

echo ""
} > "$TEMP_OUTPUT_FILE"

# Copy the generated content to the final output path
mkdir -p "$(dirname "$OUTPUT_FILE_PATH")"
cp "$TEMP_OUTPUT_FILE" "$OUTPUT_FILE_PATH"

# Clean up the temporary file
# rm "$TEMP_OUTPUT_FILE"

echo "Generated $OUTPUT_FILE_PATH for $SYMBOL_NAME."

