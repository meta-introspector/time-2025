#!/usr/bin/env bash

REPO_NAME="time-2025"
BRANCH_NAME="feature/lattice-30030-homedir"
GITHUB_ORG="meta-introspector"

while IFS= read -r line; do
  extracted_path=""

  # Try to extract path from url = "path:./..." pattern
  extracted_path=$(echo "$line" | sed -n 's#.*url[[:space:]]*=[[:space:]]*"path:\([^\"]*\)".*#\1#p')

  if [ -n "$extracted_path" ]; then
    # Remove leading ./ if present
    relative_path=$(echo "$extracted_path" | sed 's/^\.\///')
    permalink="github:${GITHUB_ORG}/${REPO_NAME}?ref=${BRANCH_NAME}&dir=${relative_path}"
    echo "Original: $line"
    echo "Permalink: $permalink"
    echo ""
  else
    # Try to extract path from "path:./some/path" or "path:some/path" (not in url = "...")
    if [[ $line =~ path:(\.\.?/[[:alnum:]/._-]+) ]]; then
      relative_path_raw="${BASH_REMATCH[1]}"
      relative_path=$(echo "$relative_path_raw" | sed 's/^\.\///')
      permalink="github:${GITHUB_ORG}/${REPO_NAME}?ref=${BRANCH_NAME}&dir=${relative_path}"
      echo "Original: $line"
      echo "Permalink: $permalink"
      echo ""
    else
      # Fallback for other path: instances (if any, or just print original)
      echo "Original: $line"
      echo "No permalink generated for this line (pattern not matched)."
      echo ""
    fi
  fi
done