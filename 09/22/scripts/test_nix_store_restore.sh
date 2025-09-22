#!/usr/bin/env bash

# Script to test the behavior of nix-store --restore

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")"/.. && pwd)"

# Source lib_exec.sh for execute_cmd function
source "${PROJECT_ROOT}/lib/lib_exec.sh"
# Source lib_utils.sh for log functions
source "${PROJECT_ROOT}/lib/lib_utils.sh"

NAR_FILE_PATH="$1"

if [ -z "$NAR_FILE_PATH" ]; then
  log_error "Usage: $0 <absolute_path_to_nar_file>"
fi

if [ ! -f "$NAR_FILE_PATH" ]; then
  log_error "NAR file not found: $NAR_FILE_PATH"
fi

log "Testing nix-store --restore behavior with NAR file: $NAR_FILE_PATH"

log "Which nix-store: $(which nix-store)"
log "Nix-store version: $(nix-store --version)"

# Use a temporary file to pipe to nix-store --restore to avoid issues with bash -c and pipes
TEMP_NAR_INPUT=$(mktemp)
execute_cmd cp "$NAR_FILE_PATH" "$TEMP_NAR_INPUT"

# Test with /dev/null
log "Testing nix-store --restore with /dev/null as input..."
if nix-store --restore < /dev/null; then
  log "nix-store --restore with /dev/null succeeded (unexpected for empty input). Output: $(nix-store --restore < /dev/null)"
else
  log "nix-store --restore with /dev/null failed as expected. Exit Code: $?"
fi

# Attempt to restore the actual NAR file without capturing output
log "Attempting to restore actual NAR file to a temporary directory..."
RESTORE_DEST_DIR=$(mktemp -d)
if nix-store --restore "$RESTORE_DEST_DIR" < "$TEMP_NAR_INPUT"; then
  log "Successfully restored NAR to: $RESTORE_DEST_DIR"
  log "Contents of restored directory:"
  ls -F "$RESTORE_DEST_DIR"
else
  log_error "Failed to restore NAR file."
fi

log "Cleaning up temporary files and directories."
execute_cmd rm -rf "$TEMP_NAR_INPUT" "$RESTORE_DEST_DIR"

log "Test script finished."
