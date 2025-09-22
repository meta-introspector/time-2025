#!/usr/bin/env bash

# scripts/generate_all_github_urls_index.sh
#
# This script generates a comprehensive list of all unique GitHub repository URLs
# found within the project, including various formats (github:owner/repo, HTTPS, SSH).
# The output is saved to index/all_github.txt.

set -euo pipefail

PROJECT_ROOT="$(dirname "$(dirname "$(realpath "$0")")")"
OUTPUT_FILE="${PROJECT_ROOT}/index/all_github.txt"

# Function to log messages
log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

log "Starting to generate comprehensive GitHub URL index. This may take a while..."

# Source the GitHub search library
source "${PROJECT_ROOT}/lib/lib_github_search.sh"

if [[ -s "${OUTPUT_FILE}" ]]; then
  log "Using existing GitHub URL index from '${OUTPUT_FILE}'. To regenerate, delete the file first."
else
  log "Generating new GitHub URL index..."
  # Use the library function to find unique GitHub URLs
  find_github_urls_in_project "${PROJECT_ROOT}" \
    | grep -vE "NixOS/nixpkgs|nix-community/" \
    > "${OUTPUT_FILE}"
  log "Finished generating GitHub URL index. URLs saved to '${OUTPUT_FILE}'."
fi

log "Found $(wc -l < "${OUTPUT_FILE}") URLs in '${OUTPUT_FILE}'."
