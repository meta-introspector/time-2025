#!/usr/bin/env bash

# This script searches for a given term within the project's index directory.

TERM="$1"

if [ -z "$TERM" ]; then
  echo "Usage: $0 <search_term>"
  echo "Example: $0 git"
  exit 1
fi

echo "Searching for '$TERM' in index/ directory..."
grep -r "$TERM" index/
