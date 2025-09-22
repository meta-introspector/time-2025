#!/usr/bin/env bash

# This script attempts to find the path of a specified Git submodule.
# It adheres to the constraint of not using direct 'git' commands.

# Argument: Submodule name (e.g., 'bootstrap')
SUBMODULE_NAME="$1"

if [ -z "$SUBMODULE_NAME" ]; then
    echo "Usage: $0 <submodule_name>"
    exit 1
fi

SUBMODULE_PATH=""

# Attempt to find the submodule path by parsing .gitmodules
# This assumes .gitmodules is in the root of the main repository.
if [ -f ".gitmodules" ]; then
    SUBMODULE_PATH=$(grep -A 1 "[submodule \"$SUBMODULE_NAME\"]" .gitmodules | grep "path =" | awk '{print $3}')
fi

if [ -z "$SUBMODULE_PATH" ]; then
    echo "Error: Could not find submodule path for '$SUBMODULE_NAME' by parsing .gitmodules."
    echo "Please provide the correct path manually or ensure .gitmodules is correctly configured."
    exit 1
else
    echo "Found submodule path for '$SUBMODULE_NAME': $SUBMODULE_PATH"
    echo "$SUBMODULE_PATH" # Output the path for use by other scripts
fi
