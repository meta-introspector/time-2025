#!/usr/bin/env bash

# This script generates review tasks for each muse and relevant document.
# Each review task will prompt the user to review a specific document
# from the perspective of a given muse.

CREATE_EXPERIMENTAL_TASK_SCRIPT="/data/data/com.termux.nix/files/home/pick-up-nix2/scripts/create_experimental_task.sh"
MUSES_SCRIPT="/data/data/com.termux.nix/files/home/pick-up-nix2/scripts/muses.sh"

DOCS_DIR="/data/data/com.termux.nix/files/home/pick-up-nix2/docs"
SCRIPTS_DIR="/data/data/com.termux.nix/files/home/pick-up-nix2/scripts"

if [ ! -f "$CREATE_EXPERIMENTAL_TASK_SCRIPT" ]; then
    echo "Error: create_experimental_task.sh not found at $CREATE_EXPERIMENTAL_TASK_SCRIPT"
    exit 1
fi

if [ ! -f "$MUSES_SCRIPT" ]; then
    echo "Error: muses.sh not found at $MUSES_SCRIPT"
    exit 1
fi

# Get the list of muses
MUSES=$($MUSES_SCRIPT --list)

if [ -z "$MUSES" ]; then
    echo "No muses found. Please populate scripts/muses.sh."
    exit 1
fi

# Get the list of documents to review
# All .md files in docs/sops/ and docs/crqs/
# All .sh files in scripts/
DOCS_TO_REVIEW=(
    $(find "$DOCS_DIR/sops" -name "*.md" -print)
    $(find "$DOCS_DIR/crqs" -name "*.md" -print)
    $(find "$SCRIPTS_DIR" -name "*.sh" -print)
)

if [ ${#DOCS_TO_REVIEW[@]} -eq 0 ]; then
    echo "No documents found for review. Please ensure docs/sops/, docs/crqs/, and scripts/ contain relevant files."
    exit 1
fi

for MUSE in $MUSES; do
    for DOC_PATH in "${DOCS_TO_REVIEW[@]}"; do
        # Extract relative path and filename for task title
        RELATIVE_DOC_PATH="${DOC_PATH#*/pick-up-nix2/}" # Remove project root prefix
        DOC_FILENAME=$(basename "$DOC_PATH")

        TASK_TITLE="Review ${MUSE} ${DOC_FILENAME}"

        # Sanitize task title for directory name (re-using logic from create_experimental_task.sh)
        SANITIZED_TASK_TITLE=$(echo "$TASK_TITLE" | sed -E 's/[^a-zA-Z0-9_-]+/-/g')
        TASK_DIR="/data/data/com.termux.nix/files/home/pick-up-nix2/tasks/${MUSE}/2025/${SANITIZED_TASK_TITLE}"
        TASK_FILE="${TASK_DIR}/task.md"

        echo "Creating review task for muse: $MUSE, document: $DOC_FILENAME with title: $TASK_TITLE"

        # Create the experimental task (this will copy the template task.md)
        "$CREATE_EXPERIMENTAL_TASK_SCRIPT" "$TASK_TITLE" || {
            echo "Error: Failed to create experimental task for $MUSE and $DOC_FILENAME."
            exit 1
        }

        # TODO: Pass context to template_generator_bin to customize task.md
        # This will involve extending create_experimental_task.sh to accept more arguments
        # and then modifying template_generator_bin to use those arguments in the template.

    done
done

echo "All review tasks created."