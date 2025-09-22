#!/usr/bin/env bash

# lib/lib_github_fork.sh
#
# This library provides a reusable function for forking GitHub repositories
# using the `gh repo fork` command. It centralizes the logic, ensures
# consistent parameter handling, and provides basic error checking.

# Function: lib_github_fork_repo
# Description: Forks a GitHub repository to a specified organization with a given fork name.
# Arguments:
#   $1: ORIGINAL_REPO_URL - The URL or owner/repo of the original repository to fork (e.g., "owner/repo" or "https://github.com/owner/repo").
#   $2: TARGET_ORG        - The GitHub organization to fork the repository into (e.g., "meta-introspector").
#   $3: FORK_NAME         - The desired name for the forked repository (e.g., "my-forked-repo").
# Returns:
#   0 if the fork operation is successful, non-zero otherwise.
# Usage:
#   lib_github_fork_repo "owner/repo" "meta-introspector" "my-forked-repo"
lib_github_fork_repo() {
    local ORIGINAL_REPO_URL="$1"
    local TARGET_ORG="$2"
    local FORK_NAME="$3"

    if [[ -z "$ORIGINAL_REPO_URL" || -z "$TARGET_ORG" || -z "$FORK_NAME" ]]; then
        echo "Error: Missing arguments for lib_github_fork_repo." >&2
        echo "Usage: lib_github_fork_repo <ORIGINAL_REPO_URL> <TARGET_ORG> <FORK_NAME>" >&2
        return 1
    fi

    echo "Attempting to fork '$ORIGINAL_REPO_URL' to '$TARGET_ORG/$FORK_NAME'..."

    # Check if the fork already exists
    if gh repo view "${TARGET_ORG}/${FORK_NAME}" &>/dev/null; then
        echo "Fork '${TARGET_ORG}/${FORK_NAME}' already exists. Skipping fork operation."
        return 0
    fi

    # Execute the gh repo fork command
    # --org: Specifies the organization to fork into.
    # --clone=false: Prevents cloning the repository after forking.
    # --fork-name: Specifies the name of the new fork.
    if gh repo fork "${ORIGINAL_REPO_URL}" --org "${TARGET_ORG}" --clone=false --fork-name "${FORK_NAME}"; then
        echo "Successfully forked '$ORIGINAL_REPO_URL' to '$TARGET_ORG/$FORK_NAME'."
        return 0
    else
        local exit_code=$?
        echo "Error: Failed to fork '$ORIGINAL_REPO_URL' to '$TARGET_ORG/$FORK_NAME'. Exit code: $exit_code" >&2
        return "$exit_code"
    fi
}

# Example Usage (for testing purposes, can be removed later)
# if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
#     echo "Running example usage..."
#     # Test case 1: Successful fork (replace with a real test repo and org)
#     # lib_github_fork_repo "cli/cli" "meta-introspector" "cli-fork-test"
#
#     # Test case 2: Missing arguments
#     # lib_github_fork_repo "cli/cli" "meta-introspector"
#
#     # Test case 3: Failed fork (e.g., repo already exists, or bad credentials)
#     # lib_github_fork_repo "cli/cli" "meta-introspector" "cli-fork-test" # Should fail if already forked
# fi
