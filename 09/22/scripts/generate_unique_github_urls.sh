#!/usr/bin/env bash

# scripts/generate_unique_github_urls.sh
#
# This script takes the comprehensive list of all GitHub URLs (index/all_github.txt)
# and generates a sorted, unique list of these URLs, saving it to index/unique_github_repos.txt.

set -euo pipefail

PROJECT_ROOT="$(dirname "$(dirname "$(realpath "$0")")")"
ALL_URLS_FILE="${PROJECT_ROOT}/index/all_github.txt"
UNIQUE_URLS_FILE="${PROJECT_ROOT}/index/unique_github_repos.txt"

# Function to log messages
log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

log "Starting to generate unique GitHub URL list."

if [[ ! -f "${ALL_URLS_FILE}" ]]; then
  log "Error: Input file '${ALL_URLS_FILE}' not found. Please run generate_all_github_urls_index.sh first."
  exit 1
fi

sort -u "${ALL_URLS_FILE}" > "${UNIQUE_URLS_FILE}"

log "Finished generating unique GitHub URL list. Unique URLs saved to '${UNIQUE_URLS_FILE}'."
log "Found $(wc -l < "${UNIQUE_URLS_FILE}") unique GitHub URLs."
