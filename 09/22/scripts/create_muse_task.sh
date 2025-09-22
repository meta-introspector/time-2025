#!/usr/bin/env bash

# This script creates a new task based on the task_template.md.
# It generates a directory structure: tasks/<muse_name>/2025/<task_title>/task.md

MUSE_NAME="$1"
TASK_TITLE="$2"
YEAR="2025"

TASK_TEMPLATE="/data/data/com.termux.nix/files/home/pick-up-nix2/templates/task_template.md"

if [ -z "$MUSE_NAME" ] || [ -z "$TASK_TITLE" ]; then
    echo "Usage: $0 <muse_name> <task_title>"
    echo "Example: $0 'StreamOfRandom' 'RefactorNixFlakes'"
    exit 1
fi

# Sanitize task title for directory name
SANITIZED_TASK_TITLE=$(echo "$TASK_TITLE" | sed -E 's/[^a-zA-Z0-9_-]+/-/g')

TASK_DIR="/data/data/com.termux.nix/files/home/pick-up-nix2/tasks/${MUSE_NAME}/${YEAR}/${SANITIZED_TASK_TITLE}"
TASK_FILE="${TASK_DIR}/task.md"

mkdir -p "$TASK_DIR"

if [ -f "$TASK_FILE" ]; then
    echo "Error: Task file already exists at $TASK_FILE. Aborting."
    exit 1
fi

cp "$TASK_TEMPLATE" "$TASK_FILE"

if [ $? -eq 0 ]; then
    echo "Successfully created new task: $TASK_FILE"
    echo "Remember to fill in the details and bless relevant documentation."
else
    echo "Error: Failed to create task file."
    exit 1
fi
