#!/usr/bin/env bash

# Debug wrapper for generate_monster_group_llm_txt.sh

set -euo pipefail

DEBUG_LOG_FILE=$(mktemp)
echo "--- Debug Wrapper: Arguments Received ---" > "$DEBUG_LOG_FILE"
echo "Number of arguments: $#" >> "$DEBUG_LOG_FILE"
for i in "$@"; do
  echo "Argument $i: $i" >> "$DEBUG_LOG_FILE"
done
echo "-----------------------------------------" >> "$DEBUG_LOG_FILE"
echo "Debug log written to: $DEBUG_LOG_FILE"

# Now execute the actual script
# Assuming generate_monster_group_llm_txt.sh is in the same directory
# and its path is passed as the first argument to this wrapper.
# We need to shift the arguments to pass them correctly to the original script.

# Parse named arguments
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --generator-script=*)
      GENERATOR_SCRIPT="${1#*=}"
      ;;
    --symbol=*)
      SYMBOL="${1#*=}"
      ;;
    --html-file-name=*)
      HTML_FILE_NAME="${1#*=}"
      ;;
    --keywords-script=*)
      KEYWORDS_SCRIPT="${1#*=}"
      ;;
    --links-file-name=*)
      LINKS_FILE_NAME="${1#*=}"
      ;;
    --tutorials-pattern=*)
      TUTORIALS_PATTERN="${1#*=}"
      ;;
    --output-dir=*)
      OUTPUT_DIR="${1#*=}"
      ;;
    --main-project=*)
      MAIN_PROJECT="${1#*=}"
      ;;
    *)
      echo "Unknown parameter passed: $1" >> "$DEBUG_LOG_FILE"
      exit 1
      ;;
  esac
  shift
done

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
