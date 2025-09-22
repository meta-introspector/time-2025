#!/usr/bin/env bash

# Get the list of cached HTML files
HTML_FILES=$(ls wikipedia_cache/*.html)

NEW_URLS=()

for file in $HTML_FILES; do
    # Extract /wiki/ links from the HTML content
    # Filter out links containing ':' (e.g., File:, Category:) and anchors (#)
    # Prepend the base Wikipedia URL
    # Use sort -u to get unique URLs
    extracted_links=$(cat "$file" | \
        grep -oE 'href="/wiki/[^"#:]+"' | \
        sed -E 's/href="//;s/"$//' | \
        sed -E 's/^/https:\/\/en.wikipedia.org/' | \
        sort -u)

    # Add to NEW_URLS array
    while IFS= read -r line; do
        NEW_URLS+=("$line")
    done <<< "$extracted_links"
done

# Get unique URLs from the collected list
UNIQUE_NEW_URLS=$(printf "%s\n" "${NEW_URLS[@]}" | sort -u)

# Output the unique new URLs
echo "$UNIQUE_NEW_NEW_URLS"
