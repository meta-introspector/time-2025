#!/usr/bin/env bash

# CRQ-018: Automated GitHub Forking for Nix Flake Dependencies
# This script identifies external GitHub Nix flake dependencies and forks them
# into the meta-introspector GitHub organization if they don't already exist.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"

# Source lib_exec.sh for execute_cmd function
source "${PROJECT_ROOT}/lib/lib_exec.sh"
# Source lib_utils.sh for log and command_exists functions
source "${PROJECT_ROOT}/lib/lib_utils.sh"
# Source lib_github.sh for fork_github_repo function
source "${PROJECT_ROOT}/lib/lib_github_fork.sh"
# Source lib_github_parsing.sh for GitHub URL parsing functions
source "${PROJECT_ROOT}/scripts/lib_github_parsing.sh"

# --- Configuration ---
META_INTROSPECTOR_ORG="meta-introspector"
GITHUB_REPOS_INDEX="${PROJECT_ROOT}/index/github_${META_INTROSPECTOR_ORG}_repos.json"
NIX_FILES_INDEX="${PROJECT_ROOT}/index/file_nix.txt"

# Function to list meta-introspector repositories
list_meta_introspector_repos() {
  log "Listing repositories in ${META_INTROSPECTOR_ORG} organization..."
  if ! command_exists gh; then
    log "Error: 'gh' (GitHub CLI) not found. Please install and authenticate."
    exit 1
  fi
  gh repo list "${META_INTROSPECTOR_ORG}" --json name,url --limit 1000 > "${GITHUB_REPOS_INDEX}"
  log "Repository list saved to ${GITHUB_REPOS_INDEX}"
}

# Function to extract GitHub dependencies from flake.nix files
extract_github_dependencies() {
  local nix_file="$1"
  # Use the new library function to extract owner/repo from github: inputs
  get_owner_repo_from_github_flake_input "$(cat "${nix_file}")" | sort -u
}

# --- Main Script Logic ---

REPORT_MODE=false
if [[ "$#" -gt 0 && "$1" == "--report" ]]; then
  REPORT_MODE=true
  log "Running in REPORT mode (dry-run)."
  shift
fi

# Ensure necessary tools are available
if ! command_exists jq; then
  log "Error: 'jq' not found. Please install it."
  exit 1
fi

# 1. List all repositories in the meta-introspector GitHub organization
list_meta_introspector_repos

# Read existing meta-introspector repositories into a jq-friendly format
META_INTROSPECTOR_REPOS=$(jq -r '.[].name' "${GITHUB_REPOS_INDEX}")

# 2. Read all flake.nix files to identify github: sources
if [[ ! -f "${NIX_FILES_INDEX}" ]]; then
  log "Error: ${NIX_FILES_INDEX} not found. Please run update_index.sh first."
  exit 1
fi

log "Identifying GitHub dependencies from flake.nix files..."
declare -A github_dependencies
while IFS= read -r nix_file_path; do
  if [[ -f "${nix_file_path}" ]]; then
    while IFS= read -r dep; do
      github_dependencies["${dep}"]=1
    done < <(extract_github_dependencies "${nix_file_path}")
  fi
done < "${NIX_FILES_INDEX}"

log "Found $(echo "${!github_dependencies[@]}" | wc -w) unique GitHub dependencies."

# 3. For each github: dependency, check if a corresponding fork exists
# 4. If a fork does not exist, check for name ambiguity
# 5. If no ambiguity and no existing fork, use gh repo fork to create a fork

for dep_repo in "${!github_dependencies[@]}"; do
  OWNER=$(echo "${dep_repo}" | cut -d'/' -f1)
  REPO_NAME=$(get_repo_name_from_github_flake_input "github:${dep_repo}")
  FORK_FULL_NAME="${META_INTROSPECTOR_ORG}/${REPO_NAME}"

  log "Processing dependency: ${dep_repo}"

  # Check if fork already exists in meta-introspector
  if echo "${META_INTROSPECTOR_REPOS}" | grep -q "^${REPO_NAME}$"; then
    log "  Fork '${FORK_FULL_NAME}' already exists. Skipping."
    continue
  fi

  # Check for name ambiguity (repo with same name but different owner)
  # This is a basic check; a more robust one might involve listing all repos on GitHub
  # and checking for name collisions. For now, we assume gh repo fork will handle
  # most common cases or fail gracefully.
  # A more thorough check would involve:
  # gh repo view "${OWNER}/${REPO_NAME}" --json name,owner --jq '.name'
  # and then comparing with existing names.
  # For now, we'll rely on gh repo fork's behavior.

  log "  Fork '${FORK_FULL_NAME}' does not exist."

  if "${REPORT_MODE}"; then
    log "  REPORT: Would fork '${dep_repo}' to '${FORK_FULL_NAME}'."
  else
    log "  Attempting to fork '${dep_repo}' to '${FORK_FULL_NAME}'..."
    if lib_github_fork_repo "${OWNER}/${REPO_NAME}" "${META_INTROSPECTOR_ORG}" "${REPO_NAME}"; then
      log "  Successfully forked '${dep_repo}' to '${FORK_FULL_NAME}'."
      # Update the local index after a successful fork
      list_meta_introspector_repos
      META_INTROSPECTOR_REPOS=$(jq -r '.[].name' "${GITHUB_REPOS_INDEX}")
    else
      log "  Error: Failed to fork '${dep_repo}' to '${FORK_FULL_NAME}'. Check 'gh' CLI output for details."
    fi
  fi
done

log "Automated dependency forking process complete."