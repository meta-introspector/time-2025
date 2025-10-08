#!/usr/bin/env bash

# This script finds all .nix files containing a specified text and
# runs their corresponding 'make test-<nix-file-name>' target.
# It can also limit the number of files processed.

if [ -z "$1" ]; then
  echo "Usage: $0 <text_to_grep_for> [num_files_to_process]"
  exit 1
fi

TEXT_TO_GREP="$1"
NUM_FILES_TO_PROCESS=${2:-0} # Default to 0 (all files) if not provided


echo "Searching for '${TEXT_TO_GREP}' in .nix files and running tests..."
echo "-------------------------------------------------------------------"

# Find all .nix files, excluding those in .git directories
NIX_FILES=$(find . -type f -name "*.nix" ! -path "./.git/*")

COUNT=0
for nix_file_path in ${NIX_FILES}; do
  if grep -q "${TEXT_TO_GREP}" "${nix_file_path}"; then
    if [ "${NUM_FILES_TO_PROCESS}" -ne 0 ] && [ "${COUNT}" -ge "${NUM_FILES_TO_PROCESS}" ]; then
      echo "Reached limit of ${NUM_FILES_TO_PROCESS} files. Stopping."
      break
    fi

    echo "Found '${TEXT_TO_GREP}' in ${nix_file_path}. Generating and testing Makefile..."
    # Call the create_develop_makefiles.sh script in test mode for this single file
    if ./scripts/create_develop_makefiles.sh "${nix_file_path}"; then
      echo "SUCCESS: Processing of ${nix_file_path} completed successfully."
    else
      echo "FAILURE: Processing of ${nix_file_path} failed. Check logs for details."
    fi
    echo "-------------------------------------------------------------------"
    COUNT=$((COUNT+1))
  fi
done

echo "Script finished."
