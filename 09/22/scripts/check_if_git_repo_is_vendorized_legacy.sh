#!/usr/bin/env bash

# This script checks if a given Git repository URL is already listed in .gitmodules.

source "$(dirname "$0")/lib_url_normalization.sh"

REPO_URL="$1"

if [ -z "$REPO_URL" ]; then
    echo "Usage: $0 <repository_url>"
    echo "Example: $0 https://github.com/owner/repo"
    exit 1
fi

echo "Checking if $REPO_URL is vendorized in .gitmodules..."

# Normalize the URL using the new function
NORMALIZED_REPO_URL=$(normalize_repo_url "$REPO_URL")

# Search for the normalized URL in .gitmodules and extract the submodule path using awk
SUBMODULE_PATH=$(awk -v url_to_find="$NORMALIZED_REPO_URL" '
    /^\[submodule / { current_submodule_line = $0; } 
    /url = / && $0 ~ url_to_find { 
        match(current_submodule_line, /"([^"]+)"/); 
        print substr(current_submodule_line, RSTART + 1, RLENGTH - 2); 
        exit; 
    }' .gitmodules)

if [ -n "$SUBMODULE_PATH" ]; then
    echo "Repository $REPO_URL (normalized to $NORMALIZED_REPO_URL) is already vendorized as submodule: $SUBMODULE_PATH"
    exit 0
else
    echo "Repository $REPO_URL (normalized to $NORMALIZED_REPO_URL) is NOT found in .gitmodules."
    exit 1
fi
