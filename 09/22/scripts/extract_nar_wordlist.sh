#!/usr/bin/env bash

# Script to extract text content from a NAR file and generate a wordlist.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"

# Source lib_exec.sh for execute_cmd function
source "${PROJECT_ROOT}/lib/lib_exec.sh"
# Source lib_utils.sh for log functions
source "${PROJECT_ROOT}/lib/lib_utils.sh"

CLEAN_AFTER_RUN=false

# Parse arguments
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --clean)
      CLEAN_AFTER_RUN=true
      shift
      ;;
    *)
      NAR_FILE_PATH="$1"
      shift
      ;;
  esac
done

if [ -z "$NAR_FILE_PATH" ]; then
  log_error "Usage: $0 <absolute_path_to_nar_file> [--clean]"
fi

if [ ! -f "$NAR_FILE_PATH" ]; then
  log_error "NAR file not found: $NAR_FILE_PATH"
fi

# Restore the NAR file to the Nix store
log "Restoring NAR file '$NAR_FILE_PATH' to Nix store..."
NIX_STORE_RESTORED_PATH=$(nix-store --restore < "$NAR_FILE_PATH") # Execute directly without execute_cmd
log "NAR restored to: $NIX_STORE_RESTORED_PATH"

# Process the extracted files to generate a wordlist
WORDLIST_FILE="$(basename "$NAR_FILE_PATH" .nar)_wordlist.txt"
log "Generating wordlist from restored content..."

# Find all text-like files (e.g., .txt, .md, .html) and concatenate their content
# Then process for wordlist generation
execute_cmd bash -c "find \"$NIX_STORE_RESTORED_PATH\" -type f \( -name '*.txt' -o -name '*.md' -o -name '*.html' \) -print0 | \
    xargs -0 cat | \
    sed -E 's/<[^>]*>//g' | \
    grep -o -E \'\\w+\' | \
    tr '[:upper:]' '[:lower:]' | \
    sort | uniq -c | sort -nr > \"$WORDLIST_FILE\""


log "Wordlist generated: $WORDLIST_FILE"

if [ "$CLEAN_AFTER_RUN" = true ]; then
  log "Cleaning up temporary files and directories."
  execute_cmd rm "$TEMP_NAR_INPUT" # Clean up temporary file
  # Note: NIX_STORE_RESTORED_PATH is in the Nix store, not a temporary directory, so it's not removed here.
fi

log "Script finished."
