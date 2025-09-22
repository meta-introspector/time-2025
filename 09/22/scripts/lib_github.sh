#!/bin/bash

# lib_github.sh: Common GitHub-related functions for shell scripts

# Ensure lib_utils.sh is sourced for logging functions
. "$(dirname "${BASH_SOURCE[0]}")/lib_utils.sh"

# Function to list repositories in a GitHub organization and save to a JSON file
# Arguments:
#   $1: GitHub organization name
#   $2: Output JSON file path
list_github_org_repos() {
  local org_name="$1"
  local output_file="$2"

  log_info "Listing repositories in ${org_name} organization..."
  if ! gh repo list "${org_name}" --json name --limit 1000 > "${output_file}"; then
    log_error "Failed to list repositories for ${org_name}. Ensure gh CLI is authenticated and has permissions."
  fi

  if [ ! -s "${output_file}" ]; then
    log_error "Failed to list repositories or ${output_file} is empty."
  fi
  log_info "Successfully listed repositories and saved to ${output_file}"
}

# Function to fork a GitHub repository into an organization
# Arguments:
#   $1: Original repository owner (e.g., 'NixOS')
#   $2: Original repository name (e.g., 'nixpkgs')
#   $3: Target GitHub organization name (e.g., 'meta-introspector')
fork_github_repo() {
  local owner="$1"
  local repo_name="$2"
  local org_name="$3"

  log_info "Attempting to fork ${owner}/${repo_name} to ${org_name}/${repo_name}..."
  if gh repo fork "${owner}/${repo_name}" --org "${org_name}" --fork-name "${repo_name}"; then
    log_info "Successfully forked ${owner}/${repo_name} to ${org_name}/${repo_name}"
    return 0
  else
    log_warn "Failed to fork ${owner}/${repo_name} to ${org_name}/${repo_name}. This might indicate an ambiguous name or a pre-existing fork with the same name. Please check manually."
    return 1
  fi
}
