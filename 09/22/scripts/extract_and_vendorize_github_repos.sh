#!/usr/bin/env bash

# scripts/extract_and_vendorize_github_repos.sh
#
# This script extracts unique GitHub repository URLs from a given input file
# (typically index/all_github.txt) and then attempts to fork each unique
# repository into the 'meta-introspector' GitHub organization using the
# lib_github_fork_repo function.

set -euo pipefail

PROJECT_ROOT="$(dirname "$(dirname "$(realpath "$0")")")"
source "${PROJECT_ROOT}/lib/lib_github_fork.sh"
source "${PROJECT_ROOT}/scripts/lib_github_parsing.sh"

# --- Configuration ---
INPUT_FILE="${PROJECT_ROOT}/index/all_github.txt"
UNIQUE_REPOS_FILE="${PROJECT_ROOT}/index/unique_github_repos.txt"
META_INTROSPECTOR_ORG="meta-introspector"

# --- Functions ---

# Function to log messages
log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# --- Main Script Logic ---

REPORT_MODE=false
if [[ "$#" -gt 0 && "$1" == "--report" ]]; then
  REPORT_MODE=true
  log "Running in REPORT mode (dry-run). No actual forking will occur."
  shift
fi

declare -A FORK_CACHE

log "Starting extraction and vendorization of GitHub repositories."

if [[ ! -f "${UNIQUE_REPOS_FILE}" ]]; then
  log "Error: Unique repositories file '${UNIQUE_REPOS_FILE}' not found. Please ensure it exists and is populated."
  exit 1
fi

log "Processing unique GitHub repositories from '${UNIQUE_REPOS_FILE}'."

log "Attempting to vendorize (fork) unique repositories to '${META_INTROSPECTOR_ORG}' organization..."

while IFS= read -r repo_url; do
  # Extract only the URL part from the "filename:url" format
  repo_url=$(echo "$repo_url" | cut -d':' -f2-)
  if [[ -z "$repo_url" ]]; then
    continue
  fi

  # Extract owner and repo name from the URL
  # Example: https://github.com/owner/repo -> owner/repo
  repo_path=$(echo "$repo_url" | sed -E 's#https?://github.com/##')
  owner=$(echo "$repo_path" | cut -d'/' -f1)
  repo_name=$(get_repo_name_from_github_url "$repo_url")
  FORK_FULL_NAME="${META_INTROSPECTOR_ORG}/${repo_name}"

  if [[ -z "$owner" || -z "$repo_name" ]]; then
    log "Warning: Could not parse owner/repo from URL: '${repo_url}'. Skipping."
    continue
  fi

  log "Processing repository: ${owner}/${repo_name}"

  # Check cache first
  if [[ -n "${FORK_CACHE[${FORK_FULL_NAME}]}" ]]; then
    if [[ "${FORK_CACHE[${FORK_FULL_NAME}]}" == "exists" ]]; then
      log "  Fork '${FORK_FULL_NAME}' already exists (cached). No action needed."
      continue
    fi
  else
    # If not in cache, check live and update cache
    if gh repo view "${FORK_FULL_NAME}" &>/dev/null; then
      FORK_CACHE[${FORK_FULL_NAME}]="exists"
      log "  Fork '${FORK_FULL_NAME}' already exists. No action needed."
      continue # Skip to next repo if already exists
    else
      FORK_CACHE[${FORK_FULL_NAME}]="not_exists"
    fi
  fi

  if "${REPORT_MODE}"; then
    if [[ "${FORK_CACHE[${FORK_FULL_NAME}]}" == "not_exists" ]]; then
      log "  REPORT: Would fork '${owner}/${repo_name}' to '${FORK_FULL_NAME}'."
    fi
  else
    # Only fork if it doesn't exist
    if [[ "${FORK_CACHE[${FORK_FULL_NAME}]}" == "not_exists" ]]; then
      # Call the lib_github_fork_repo function
      if lib_github_fork_repo "${owner}/${repo_name}" "${META_INTROSPECTOR_ORG}" "${repo_name}"; then
        log "Successfully vendorized (forked) ${owner}/${repo_name}."
      else
        log "Error: Failed to vendorize (fork) ${owner}/${repo_name}. See previous logs for details."
      fi
    fi
  fi
done < "${UNIQUE_REPOS_FILE}"

log "GitHub repository extraction and vendorization process complete."
