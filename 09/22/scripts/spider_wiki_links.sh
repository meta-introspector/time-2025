#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Source the lib_exec.sh library for execute_cmd
source "/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/22/lib/lib_exec.sh"

# Get the list of cached HTML files
HTML_FILES=$(execute_cmd ls wikipedia_cache/*.html)

NEW_URLS=()

for file in $HTML_FILES; do
    # Extract /wiki/ links from the HTML content
    # Filter out links containing ':' (e.g., File:, Category:) and anchors (#)
    # Prepend the base Wikipedia URL
    # Use sort -u to get unique URLs
    extracted_links=$(execute_cmd bash -c "< \"$file\" |
        grep -oE 'href=\"/wiki/[^"#:]+\"' |
        sed -E \"s/href=\\\"//;s/\\\"$//\" |
        sed -E \"s/^/https:\/\/en.wikipedia.org\//\" |
        sort -u")

    # Add to NEW_URLS array
    while IFS= read -r line; do
        NEW_URLS+=("$line")
    done <<< "$extracted_links"
done

# Get unique URLs from the collected list
UNIQUE_NEW_URLS=$(execute_cmd bash -c "printf \"%s\\n\" \"${NEW_URLS[@]}\" | sort -u")

# Output the unique new URLs
execute_cmd echo "$UNIQUE_NEW_URLS"
