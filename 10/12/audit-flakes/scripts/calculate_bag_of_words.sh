#!/usr/bin/env bash

set -euo pipefail

# This script calculates the bag of words from NIX_FILE_CONTENT
# It expects NIX_FILE_CONTENT to be provided via stdin or as an argument.

# Read NIX_FILE_CONTENT from stdin if not provided as argument
if [ -t 0 ]; then # Check if stdin is a terminal
  if [ -z "${1:-}" ]; then
    echo "Usage: $0 <NIX_FILE_CONTENT>"
    exit 1
  fi
  NIX_FILE_CONTENT="$1"
else
  NIX_FILE_CONTENT=$(cat)
fi

# Define the base directory for the flakes (needed for bag_of_words.jq)
FLAKE_BASE_DIR="$(dirname "$(dirname "$(realpath "$0")")")"

printf %b "$NIX_FILE_CONTENT" | \
  tr '[:upper:]' '[:lower:]' | \
  sed -E 's/([a-z0-9])([A-Z])/\1 \2/g' | \
  sed -E 's/[-_]/ /g' | \
  sed -E "s/[^a-z0-9 ]+//g" | \
  sed -E "s/ +/ /g" | \
  grep -oE '[a-z0-9]+' | \
  sort | \
  uniq -c | \
  jq -Rsc -f "${FLAKE_BASE_DIR}/scripts/bag_of_words.jq"
