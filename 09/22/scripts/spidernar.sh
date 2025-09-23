#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status.
set -euo pipefail

# Source the lib_exec.sh library for execute_cmd
source "$(dirname "$0")/lib/lib_exec.sh"

NAR_FILE="$1"

if [ -z "$NAR_FILE" ]; then
  execute_cmd echo "Usage: $0 <NAR_FILE>"
  exit 1
fi

if [ ! -f "$NAR_FILE" ]; then
  execute_cmd echo "Error: NAR file not found: $NAR_FILE"
  exit 1
fi

execute_cmd echo "Spidering NAR file: $NAR_FILE"

# Create a temporary directory for extraction
TEMP_DIR=$(mktemp -d)
execute_cmd echo "Extracting NAR to temporary directory: $TEMP_DIR"

# Extract the NAR file
# nix-store --restore outputs the path to stdout.
NIX_STORE_PATH=$(nix-store --restore < "$NAR_FILE")
execute_cmd echo "NAR restored to Nix store path: $NIX_STORE_PATH"

# Now, we need to copy the contents from the Nix store path to our temporary directory
# so we can process them.
execute_cmd cp -r "$NIX_STORE_PATH"/* "$TEMP_DIR/"

NEW_URLS=()

# Find all HTML files in the extracted content
HTML_FILES=$(find "$TEMP_DIR" -type f -name "*.html")

if [ -z "$HTML_FILES" ]; then
    execute_cmd echo "No HTML files found in the NAR archive."
else
    for file in $HTML_FILES; do
        # Extract /wiki/ links from the HTML content
        # Filter out links containing ':' (e.g., File:, Category:) and anchors (#)
        # Prepend the base Wikipedia URL
        # Use sort -u to get unique URLs
        extracted_links=$(cat "$file" |
            grep -oE 'href="/wiki/[^"#:]+"' |
            sed -E 's/href="//;s/"$//' |
            sed -E 's/^/https:\/\/en.wikipedia.org\//' |
            sort -u)

        # Add to NEW_URLS array
        while IFS= read -r line; do
            NEW_URLS+=("$line")
        done <<< "$extracted_links"
    done
fi

# Get unique URLs from the collected list
UNIQUE_NEW_URLS=$(printf "%s\n" "${NEW_URLS[@]}" | sort -u)

# Output the unique new URLs
execute_cmd echo "$UNIQUE_NEW_URLS"

# Clean up the temporary directory
execute_cmd echo "Cleaning up temporary directory: $TEMP_DIR"
execute_cmd rm -rf "$TEMP_DIR"

execute_cmd echo "Spidering NAR file complete."
