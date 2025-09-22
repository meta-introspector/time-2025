#!/usr/bin/env bash

# scripts/generate_github_prefix_counts.sh
#
# This script processes the comprehensive list of all GitHub URLs (index/all_github.txt)
# to count occurrences of URL prefixes (first 5 slash-separated fields).
# The output is saved to index/all_github_5.txt.

set -euo pipefail

PROJECT_ROOT="$(dirname "$(dirname "$(realpath "$0")")")"
ALL_URLS_FILE="${PROJECT_ROOT}/index/all_github.txt"
OUTPUT_FILE="${PROJECT_ROOT}/index/all_github_5.txt"

# Function to log messages
log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

log "Starting to generate GitHub URL prefix counts."

if [[ ! -f "${ALL_URLS_FILE}" ]]; then
  log "Error: Input file '${ALL_URLS_FILE}' not found. Please run generate_all_github_urls_index.sh first."
  exit 1
fi

cut -d/ -f1-5 "${ALL_URLS_FILE}" | sort | uniq -c | sort -n > "${OUTPUT_FILE}"

log "Finished generating GitHub URL prefix counts. Counts saved to '${OUTPUT_FILE}'."
log "Found $(wc -l < "${OUTPUT_FILE}") unique prefixes."
