#!/usr/bin/env bash

# lib_url_normalization.sh
# This library provides functions for normalizing Git repository URLs.

# Function to normalize a Git repository URL to a consistent HTTPS format,
# and replace the owner with 'meta-introspector' if it's a GitHub URL.
# The normalized URL will NOT include a '.git' suffix.
# Usage: normalize_repo_url <repository_url>
# Example: normalize_repo_url github:owner/repo -> https://github.com/meta-introspector/repo
normalize_repo_url() {
    local raw_url="$1"
    local normalized_url=""
    local owner=""
    local repo_name=""

    # Step 1: Normalize to a consistent HTTPS format and extract owner/repo_name
    # Handle github:owner/repo format
    if [[ "$raw_url" =~ ^github:([^/]+)/([^/]+)$ ]]; then
        owner="${BASH_REMATCH[1]}"
        repo_name="${BASH_REMATCH[2]%.git}" # Remove .git if present
        normalized_url="https://github.com/${owner}/${repo_name}"
    # Handle git@github.com:owner/repo.git format
    elif [[ "$raw_url" =~ ^git@github.com:([^/]+)/([^/]+)(\.git)?$ ]]; then
        owner="${BASH_REMATCH[1]}"
        repo_name="${BASH_REMATCH[2]%.git}" # Remove .git if present
        normalized_url="https://github.com/${owner}/${repo_name}"
    # Handle https://github.com/owner/repo(.git)? format
    elif [[ "$raw_url" =~ ^https:\/\/github.com\/([^/]+)/([^/]+)(\.git)?$ ]]; then
        owner="${BASH_REMATCH[1]}"
        repo_name="${BASH_REMATCH[2]%.git}" # Remove .git if present
        normalized_url="https://github.com/${owner}/${repo_name}"
    else
        # If it's not a GitHub URL, or a format we don't recognize, return as is.
        # Also, ensure any .git suffix is removed for consistency if it's a direct URL
        echo "${raw_url%.git}"
        return
    fi

    # Step 2: Replace owner with 'meta-introspector' if it's a GitHub URL and not already meta-introspector
    if [[ "$normalized_url" =~ ^https:\/\/github.com\/ ]] && [[ "$owner" != "meta-introspector" ]]; then
        normalized_url="https://github.com/meta-introspector/${repo_name}"
    fi

    echo "$normalized_url"
}