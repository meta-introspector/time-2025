#!/usr/bin/env bash

# Utility functions for temporary file management.

# Creates a temporary file and prints its path to stdout.
create_temp_file() {
  mktemp
}

# Cleans up a temporary file.
cleanup_temp_file() {
  local temp_file="$1"
  if [[ -f "$temp_file" ]]; then
    rm "$temp_file"
  fi
}
