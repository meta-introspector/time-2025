#!/usr/bin/env bash

# This script creates a new experimental task based on the task_template.md.
# It now uses the sed-based template generator script to create the project structure.

# Source the time utility library
source "/data/data/com.termux.nix/files/home/pick-up-nix2/lib/lib_time.sh"

MUSE_NAME="$2"
TASK_TITLE="$1"

if [ -z "$TASK_TITLE" ] || [ -z "$MUSE_NAME" ]; then
    echo "Usage: $0 <task_title> <muse_name>"
    echo "Example: $0 'InvestigateNixFlakeBehavior' 'DigitalMycology'"
    exit 1
fi

# Sanitize task title for directory name
SANITIZED_TASK_TITLE=$(echo "$TASK_TITLE" | sed -E 's/[^a-zA-Z0-9_-]+/-/g')

# Get current date for directory structure
CURRENT_DATE=$(get_current_date_yyyymmdd)
CURRENT_YEAR=$(echo "$CURRENT_DATE" | cut -d'/' -f1)

TASK_DIR="/data/data/com.termux.nix/files/home/pick-up-nix2/tasks/${MUSE_NAME}/${CURRENT_YEAR}/${CURRENT_DATE}/${SANITIZED_TASK_TITLE}"

# Ensure the output directory exists
mkdir -p "$TASK_DIR"

# Call the sed-based script to generate the task
# Pass all necessary parameters to the sed script
if /data/data/com.termux.nix/files/home/pick-up-nix2/scripts/create_experimental_task_sed.sh "$TASK_TITLE" "$MUSE_NAME"; then
    echo "Successfully created new experimental task: ${TASK_DIR}/task.md"
else
    echo "Error: Failed to create task file."
    exit 1
fi
