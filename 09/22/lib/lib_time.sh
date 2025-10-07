#!/usr/bin/env bash

# lib/lib_time.sh
# Provides utility functions for time and date formatting, and task directory creation.

# Function to get the current date in YYYY/MM/DD format.
get_current_date_yyyymmdd() {
    date +%Y/%m/%d
}

# Function to get the current year in YYYY format.
get_current_year_yyyy() {
    date +%Y
}

# Function to create a task directory and return its path.
# Arguments: $1 = TASK_TITLE
create_task_directory() {
    local TASK_TITLE="$1"
    local DATE_PATH
    DATE_PATH=$(date +%Y/%m/%d) # Get YYYY/MM/DD for path

    # Sanitize task title for directory name
    local SANITIZED_TASK_TITLE
    SANITIZED_TASK_TITLE=$(echo "$TASK_TITLE" | sed -E 's/[^a-zA-Z0-9_-]+/-/g')

    # Updated TASK_DIR structure
    local TASK_DIR="/data/data/com.termux.nix/files/home/pick-up-nix2/tasks/${DATE_PATH}/${SANITIZED_TASK_TITLE}"

    # Ensure the output directory exists
    mkdir -p "$TASK_DIR" || { echo "Error: Failed to create directory $TASK_DIR"; return 1; }

    echo "$TASK_DIR"
    return 0
}
