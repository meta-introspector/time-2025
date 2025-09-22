#!/usr/bin/env bash

set -euo pipefail

# Find all flake.nix files and grep for 'url', outputting filename:line_content
find . -name flake.nix -exec grep -H 'url' {} \; > index/flake_nix_urls_with_filenames.txt

# Process the URLs to count unique occurrences (optional, but useful for analysis)
cut -d= -f2 index/flake_nix_urls_with_filenames.txt | sort | uniq -c | sort -n > index/flake_nix_urls_count.txt
