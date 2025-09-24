#!/usr/bin/env bash

set -euo pipefail

echo "Discovering URLs within the project..."

# Define file types to search
FILE_TYPES="md|nix|sh|json|txt|org"

# Define directories to exclude
EXCLUDE_DIRS=(
  ".git"
  "node_modules"
  "vendor"
  "result"
  "nix/store"
  "crq-binstore" # Exclude the binary store itself
  "cache"
  "generated-tasks"
  "wikipedia_cache"
)

# Build the find command's exclude arguments as an array
FIND_ARGS=()
for dir in "${EXCLUDE_DIRS[@]}"; do
  FIND_ARGS+=( "-path" "./$dir" "-prune" "-o" )
done
# Add a dummy -true argument at the end if FIND_ARGS is not empty,
# to correctly terminate the -o (OR) logic for find.
if [ ${#FIND_ARGS[@]} -gt 0 ]; then
  FIND_ARGS+=( "-true" )
fi

# Use find to locate relevant files and grep to extract URLs
# The regex looks for http(s):// followed by non-whitespace characters
# It also tries to capture common URL characters like hyphens, dots, slashes, etc.
find . -type f \
  "${FIND_ARGS[@]}" \
  -regex ".*\\.\(\${FILE_TYPES}\)$" -print0 \
  | xargs -0 grep -o -E "https?://[a-zA-Z0-9./?#&=_%~-]+" \
  | sort -u


echo "URL discovery complete."
