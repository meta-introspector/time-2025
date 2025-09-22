#!/usr/bin/env bash

STATUS_FILE="/data/data/com.termux.nix/files/home/pick-up-nix2/index/submodules_status.txt"
PROJECT_ROOT="/data/data/com.termux.nix/files/home/pick-up-nix2"
#DRY_RUN=true # Set to true for dry run, false to actually execute

echo "Starting restoration of deleted files in submodules (Dry Run: $DRY_RUN)..."

current_submodule=""
deleted_found=false

# Read the status file line by line
while IFS= read -r line; do
    if [[ "$line" =~ ^Entering\ \'(.+)\'$ ]]; then
        # If we were processing a submodule and found deleted files, process them
        if [ "$deleted_found" = true ]; then
            echo "Processing submodule: ${current_submodule}"
            if [ "$DRY_RUN" = true ]; then
                echo "  Would run: (cd \"${PROJECT_ROOT}/${current_submodule}\" && git restore --staged .)"
                echo "  Would run: (cd \"${PROJECT_ROOT}/${current_submodule}\" && git checkout .)"
            else
                (cd "${PROJECT_ROOT}/${current_submodule}" && git restore --staged .)
                (cd "${PROJECT_ROOT}/${current_submodule}" && git checkout .)
            fi
        fi
        # Reset for the new submodule
        current_submodule="${BASH_REMATCH[1]}"
        deleted_found=false
    elif [[ "$line" =~ ^[[:space:]]+deleted: ]]; then
        # Mark that deleted files are found in the current submodule
        deleted_found=true
    fi
done < "$STATUS_FILE"

# Check for the last submodule in case the file ends with deleted files
if [ "$deleted_found" = true ]; then
    echo "Restoring deleted files in submodule: ${current_submodule}"
    if [ "$DRY_RUN" = true ]; then
        echo "  Would run: (cd \"${PROJECT_ROOT}/${current_submodule}\" && git restore --staged .)"
        echo "  Would run: (cd \"${PROJECT_ROOT}/${current_submodule}\" && git checkout .)"
    else
        (cd "${PROJECT_ROOT}/${current_submodule}" && git restore --staged .)
        (cd "${PROJECT_ROOT}/${current_submodule}" && git checkout .)
    fi
fi

echo "Restoration process complete."
