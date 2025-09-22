#!/usr/bin/env bash

set -e

PROJECT_ROOT="/data/data/com.termux.nix/files/home/pick-up-nix2"
STATUS_FILE="${PROJECT_ROOT}/index/submodules_status.txt"
CRQ_NUMBER="016"
BRANCH_NAME="feature/CRQ-016-nixify-workflow"

echo "Starting to commit and push changes in submodules..."

# Read the status file line by line
current_submodule=""
while IFS= read -r line; do
    if [[ "$line" =~ ^Entering\ \'(.+)\'$ ]]; then
        current_submodule="${BASH_REMATCH[1]}"
        submodule_full_path="${PROJECT_ROOT}/${current_submodule}"
    elif [[ "$line" =~ ^(Changes\ not\ staged\ for\ commit:|Untracked\ files:|Your\ branch\ is\ ahead\ of\ 'origin') ]]; then
        # If we detect any changes or new commits, process this submodule
        echo "--- Processing submodule: ${current_submodule} ---"
        
        # Ensure the correct branch is checked out in the submodule
        (
            cd "$submodule_full_path"
            if git rev-parse --verify "$BRANCH_NAME" &>/dev/null; then
                echo "Branch $BRANCH_NAME already exists. Checking it out."
                git checkout "$BRANCH_NAME"
            else
                echo "Branch $BRANCH_NAME does not exist. Creating and checking it out."
                git checkout -b "$BRANCH_NAME"
            fi
        )

        # Commit changes using the dedicated script
        # The commit message will be general for now, can be refined later if needed per submodule
        ./scripts/commit_crq_submodule.sh "$current_submodule" "$CRQ_NUMBER" "Automated commit for CRQ-016 changes"

        # Push the changes
        (
            cd "$submodule_full_path"
            echo "Pushing changes to origin HEAD..."
            git push origin HEAD
        )
        echo "--- Finished processing ${current_submodule} ---"
    fi
done < "$STATUS_FILE"

echo "Completed committing and pushing changes in submodules."
