#!/usr/bin/env bash

# Script to simulate a Nix build environment and call debug_wrapper.sh

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"

# Source lib_utils.sh for log functions
source "${PROJECT_ROOT}/lib/lib_utils.sh"

# Define dummy arguments for debug_wrapper.sh
GENERATOR_SCRIPT_PATH="${PROJECT_ROOT}/nix-llm-context/generate_monster_group_llm_txt.sh"
SYMBOL="Test Symbol"
HTML_FILE_NAME="Monster_group.html"
KEYWORDS_SCRIPT_FILE_NAME="extract_meaningful_keywords.sh"
LINKS_FILE_NAME="all_extracted_links.md"
TUTORIALS_PATTERN="*monster_group*_tiktok_tutorial.md"
OUTPUT_DIR="${PROJECT_ROOT}/scripts/nix-simulated-output"
MAIN_PROJECT_PATH="${PROJECT_ROOT}"

# Create dummy output directory
mkdir -p "$OUTPUT_DIR"

log "Calling debug_wrapper.sh with simulated Nix arguments..."

# Call debug_wrapper.sh with named arguments
ARGS=(
  "--generator-script" "$GENERATOR_SCRIPT_PATH"
  "--symbol" "$SYMBOL"
  "--html-file-name" "$HTML_FILE_NAME"
  "--keywords-script" "$KEYWORDS_SCRIPT_FILE_NAME"
  "--links-file-name" "$LINKS_FILE_NAME"
  "--tutorials-pattern" "$TUTORIALS_PATTERN"
  "--output-dir" "$OUTPUT_DIR"
  "--main-project" "$MAIN_PROJECT_PATH"
)

echo "${PROJECT_ROOT}/nix-llm-context/debug_wrapper.sh" "${ARGS[@]}"
"${PROJECT_ROOT}/nix-llm-context/debug_wrapper.sh" "${ARGS[@]}"

log "Debug log from debug_wrapper.sh:"
cat "${OUTPUT_DIR}/debug_log.txt"

log "Simulated run finished. Check $OUTPUT_DIR for generated files."
