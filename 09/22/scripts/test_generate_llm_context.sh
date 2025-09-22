#!/usr/bin/env bash

# Test harness for generate_monster_group_llm_txt.sh

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"

# Source lib_utils.sh for log functions
source "${PROJECT_ROOT}/lib/lib_utils.sh"

# Define dummy arguments
DUMMY_SYMBOL="Monster Group"
DUMMY_HTML_FILE="${PROJECT_ROOT}/wikipedia_cache/Monster_group.html"
DUMMY_KEYWORDS_SCRIPT="${PROJECT_ROOT}/docs/memes/extract_meaningful_keywords.sh"
DUMMY_LINKS_FILE="${PROJECT_ROOT}/docs/memes/all_extracted_links.md"
DUMMY_TUTORIALS_PATTERN="${PROJECT_ROOT}/docs/memes/*test*_tiktok_tutorial.md"
DUMMY_OUTPUT_FILE="/tmp/test-llm-context.txt"
DUMMY_MAIN_PROJECT_PATH="${PROJECT_ROOT}"

# Create dummy files for the test
mkdir -p "${PROJECT_ROOT}/wikipedia_cache"
touch "${DUMMY_HTML_FILE}"
mkdir -p "${PROJECT_ROOT}/docs/memes"
touch "${DUMMY_KEYWORDS_SCRIPT}"
touch "${DUMMY_LINKS_FILE}"
touch "${PROJECT_ROOT}/docs/memes/test_tiktok_tutorial.md"

log "Running generate_monster_group_llm_txt.sh with dummy arguments... (Output will be in /tmp/test-llm-context.txt)"

# Execute the script
"${PROJECT_ROOT}/nix-llm-context/generate_monster_group_llm_txt.sh" \
  "${DUMMY_SYMBOL}" \
  "${DUMMY_HTML_FILE}" \
  "${DUMMY_KEYWORDS_SCRIPT}" \
  "${DUMMY_LINKS_FILE}" \
  "${DUMMY_TUTORIALS_PATTERN}" \
  "${DUMMY_OUTPUT_FILE}" \
  "${DUMMY_MAIN_PROJECT_PATH}"

EXIT_CODE=$?

if [ "$EXIT_CODE" -eq 0 ]; then
  log "Script executed successfully. Output written to ${DUMMY_OUTPUT_FILE}"
  cat "${DUMMY_OUTPUT_FILE}"
else
  log_error "Script failed with exit code $EXIT_CODE."
fi

log "Test harness finished."
