#!/usr/bin/env bash

set -e

LOG_FILE="index/process_all_flake_submodules.log"

echo "Starting submodule flake processing at $(date)" | tee -a "$LOG_FILE"

# Get all submodule paths
SUBMODULE_PATHS=$(grep "^Entering '" "index/submodules_status.txt" | sed -n "s/^Entering '\(.*\)'$/\1/p")

if [ -z "$SUBMODULE_PATHS" ]; then
    echo "No submodules found." | tee -a "$LOG_FILE"
    exit 0
fi

for submodule_path in $SUBMODULE_PATHS; do
    echo "Checking submodule: ${submodule_path}" | tee -a "$LOG_FILE"
    if [ -f "${submodule_path}/flake.nix" ]; then
        echo "Found flake.nix in ${submodule_path}. Processing..." | tee -a "$LOG_FILE"
        # Execute commit_and_push_flakes.sh for the specific submodule
        ./scripts/commit_and_push_flakes.sh "${submodule_path}" | tee -a "$LOG_FILE"
        echo "Finished processing ${submodule_path}" | tee -a "$LOG_FILE"
    else
        echo "No flake.nix found in ${submodule_path}. Skipping." | tee -a "$LOG_FILE"
    fi
done

echo "Finished submodule flake processing at $(date)" | tee -a "$LOG_FILE"
