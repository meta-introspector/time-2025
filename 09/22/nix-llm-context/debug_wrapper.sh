#!/usr/bin/env bash

# Debug wrapper for generate_monster_group_llm_txt.sh

set -euo pipefail

# Parse named arguments
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --generator-script)
      GENERATOR_SCRIPT="$2"
      shift
      ;;
    --generator-script=*)
      GENERATOR_SCRIPT="${1#*=}"
      ;;
    --symbol)
      SYMBOL="$2"
      shift
      ;;
    --symbol=*)
      SYMBOL="${1#*=}"
      ;;
    --html-file-name)
      HTML_FILE_NAME="$2"
      shift
      ;;
    --html-file-name=*)
      HTML_FILE_NAME="${1#*=}"
      ;;
    --keywords-script)
      KEYWORDS_SCRIPT="$2"
      shift
      ;;
    --keywords-script=*)
      KEYWORDS_SCRIPT="${1#*=}"
      ;;
    --links-file-name)
      LINKS_FILE_NAME="$2"
      shift
      ;;
    --links-file-name=*)
      LINKS_FILE_NAME="${1#*=}"
      ;;
    --tutorials-pattern)
      TUTORIALS_PATTERN="$2"
      shift
      ;;
    --tutorials-pattern=*)
      TUTORIALS_PATTERN="${1#*=}"
      ;;
    --output-dir)
      OUTPUT_DIR="$2"
      shift
      ;;
    --output-dir=*)
      OUTPUT_DIR="${1#*=}"
      ;;
    --main-project)
      MAIN_PROJECT="$2"
      shift
      ;;
    --main-project=*)
      MAIN_PROJECT="${1#*=}"
      ;;
    *)
      echo "Unknown parameter passed: $1" # Log to stderr for now
      exit 1
      ;;
  esac
  shift
done

mkdir -p "$OUTPUT_DIR"
DEBUG_LOG_FILE="$OUTPUT_DIR/debug_log.txt"
echo "--- Debug Wrapper: Arguments Received ---" > "$DEBUG_LOG_FILE"
echo "Number of arguments: $#" >> "$DEBUG_LOG_FILE"
for i in "$@"; do
  echo "Argument $i: $i" >> "$DEBUG_LOG_FILE"
done
echo "-----------------------------------------" >> "$DEBUG_LOG_FILE"
echo "Debug log written to: $DEBUG_LOG_FILE"

# Construct the arguments for the original script
# These must match the positional arguments expected by generate_monster_group_llm_txt.sh
ARGS=(
  "$SYMBOL"
  "${MAIN_PROJECT}/wikipedia_cache/${HTML_FILE_NAME}"
  "${MAIN_PROJECT}/docs/memes/${KEYWORDS_SCRIPT}"
  "${MAIN_PROJECT}/docs/memes/${LINKS_FILE_NAME}"
  "${MAIN_PROJECT}/docs/memes/${TUTORIALS_PATTERN}"
  "${OUTPUT_DIR}/llm-context-${SYMBOL// /-}.txt" # Construct output file path
  "${MAIN_PROJECT}"
)

# Execute the original script with the constructed arguments
exec "$GENERATOR_SCRIPT" "${ARGS[@]}"
