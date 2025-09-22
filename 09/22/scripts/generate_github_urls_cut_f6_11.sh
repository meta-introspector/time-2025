#!/usr/bin/env bash

# scripts/generate_github_urls_cut_f6_11.sh
#
# This script processes the comprehensive list of all GitHub URLs (index/all_github.txt)
# by extracting specific parts of the URL and counting their occurrences.
# The output is saved to index/all_github_urls2.txt.

set -euo pipefail

PROJECT_ROOT="$(dirname "$(dirname "$(realpath "$0")")")"
ALL_URLS_FILE="${PROJECT_ROOT}/index/all_github.txt"
OUTPUT_FILE="${PROJECT_ROOT}/index/all_github_urls2.txt"

# Function to log messages
log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

log "Starting to generate GitHub URL parts counts (cut -f6-11)."

if [[ ! -f "${ALL_URLS_FILE}" ]]; then
  log "Error: Input file '${ALL_URLS_FILE}' not found. Please run generate_all_github_urls_index.sh first."
  exit 1
fi

cut -d: -f1 "${ALL_URLS_FILE}" | cut -d/ -f6-11 | sort | uniq -c | sort -n > "${OUTPUT_FILE}"

log "Finished generating GitHub URL parts counts. Counts saved to '${OUTPUT_FILE}'."
log "Found $(wc -l < "${OUTPUT_FILE}") unique URL parts."
