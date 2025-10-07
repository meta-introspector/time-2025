#!/usr/bin/env bash

# lib/lib_github_search.sh
#
# This library provides functions for searching and extracting GitHub URLs
# from the project codebase.

set -euo pipefail

# Function to find unique GitHub URLs within a specified path or the entire project.
# Usage: find_github_urls_in_project [search_path]
# Output: A list of unique GitHub URLs (normalized to HTTPS) to stdout.
find_github_urls_in_project() {
  local search_path="${1:-$(pwd)}"

  # Use a combination of regexes to find various GitHub URL formats
  # - github:owner/repo
  # - https://github.com/owner/repo
  # - git@github.com:owner/repo.git

  # The 'grep -oE' command extracts only the matching parts.
  # The 'sed' commands normalize SSH and github:owner/repo URLs to HTTPS
  # for easier unique identification.
  # The 'sort -u' command ensures only unique URLs are listed.

  grep -r -oE 'github:[^/"[:space:]]+/[^/"[:space:]]+|https?://github.com/[a-zA-Z0-9_.-]+/[a-zA-Z0-9_.-]+|git@github.com:[a-zA-Z0-9_.-]+/[a-zA-Z0-9_.-]+\.git' \
    "${search_path}" \
    | sed -E 's#git@github.com:([^/]+)/([^/]+)\.git#https://github.com/\1/\2#' \
    | sed -E 's#github:([^/]+)/([^/]+)#https://github.com/\1/\2#' \
    
}
