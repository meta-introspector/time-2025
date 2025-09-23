#!/usr/bin/env bash

# lib_exec.sh: Utility functions for command execution.

# Global variable to control dry-run mode.
# Should be set to 'true' for dry-run, 'false' otherwise.
DRY_RUN=false

# Function to execute a command, with an optional dry-run mode.
# Arguments:
#   $@: The command and its arguments to execute.
execute_cmd() {
  if [ "$DRY_RUN" = true ]; then
    echo "[DRY RUN] Would execute: \"$@\""
  else
    echo "[EXEC] \"$@\""
    "$@"
  fi
}
