#!/usr/bin/env bash

# This script creates a new experimental task based on a Markdown template,
# using sed for placeholder replacement.

# Source the time utility library
source "/data/data/com.termux.nix/files/home/pick-up-nix2/lib/lib_time.sh"

TASK_TITLE="$1"
MUSE_NAME="$2"
DATE=$(get_current_date_yyyymmdd) # Use function from lib_time.sh

if [ -z "$TASK_TITLE" ] || [ -z "$MUSE_NAME" ]; then
    echo "Usage: $0 <task_title> <muse_name>"
    echo "Example: $0 'InvestigateNixFlakeBehavior' 'DigitalMycology'"
    exit 1
fi

# Create task directory and get its path
TASK_DIR=$(create_task_directory "$TASK_TITLE") || exit 1

# --- Generate task.md ---
TEMPLATE_FILE_MD="/data/data/com.termux.nix/files/home/pick-up-nix2/templates/experimental_task.md.template"
OUTPUT_FILE_MD="${TASK_DIR}/task.md"

sed -e "s|{{TASK_TITLE}}|${TASK_TITLE}|g" \
    -e "s|{{MUSE_NAME}}|${MUSE_NAME}|g" \
    -e "s|{{DATE}}|${DATE}|g" \
    "$TEMPLATE_FILE_MD" > "$OUTPUT_FILE_MD" || { echo "Error: Failed to generate task.md file."; exit 1; }

if [ -f "$OUTPUT_FILE_MD" ]; then
    echo "Successfully created new experimental task: $OUTPUT_FILE_MD"
else
    echo "Error: Failed to create task.md file."
    exit 1
fi

# --- Generate boot.sh ---
TEMPLATE_FILE_BOOT="/data/data/com.termux.nix/files/home/pick-up-nix2/templates/experiment_boot.sh.template"
OUTPUT_FILE_BOOT="${TASK_DIR}/boot.sh"

sed -e "s|{{TASK_TITLE}}|${TASK_TITLE}|g" \
    -e "s|{{MUSE_NAME}}|${MUSE_NAME}|g" \
    "$TEMPLATE_FILE_BOOT" > "$OUTPUT_FILE_BOOT" || { echo "Error: Failed to generate boot.sh file."; exit 1; }

chmod +x "$OUTPUT_FILE_BOOT" || { echo "Error: Failed to set execute permissions for boot.sh."; exit 1; }

if [ -f "$OUTPUT_FILE_BOOT" ]; then
    echo "Successfully created boot.sh: $OUTPUT_FILE_BOOT"
else
    echo "Error: Failed to create boot.sh file."
    exit 1
fi

# --- Generate flake.nix ---
TEMPLATE_FILE_FLAKE="/data/data/com.termux.nix/files/home/pick-up-nix2/templates/experiment_flake.nix.template"
OUTPUT_FILE_FLAKE="${TASK_DIR}/flake.nix"

sed -e "s|{{TASK_TITLE}}|${TASK_TITLE}|g" \
    -e "s|{{MUSE_NAME}}|${MUSE_NAME}|g" \
    "$TEMPLATE_FILE_FLAKE" > "$OUTPUT_FILE_FLAKE" || { echo "Error: Failed to generate flake.nix file."; exit 1; }

if [ -f "$OUTPUT_FILE_FLAKE" ]; then
    echo "Successfully created flake.nix: $OUTPUT_FILE_FLAKE"
else
    echo "Error: Failed to create flake.nix file."
    exit 1
fi

# --- Generate run_experiment.sh ---
TEMPLATE_FILE_RUN="/data/data/com.termux.nix/files/home/pick-up-nix2/templates/run_experiment.sh.template"
OUTPUT_FILE_RUN="${TASK_DIR}/run_experiment.sh"

sed -e "s|{{TASK_TITLE}}|${TASK_TITLE}|g" \
    -e "s|{{MUSE_NAME}}|${MUSE_NAME}|g" \
    "$TEMPLATE_FILE_RUN" > "$OUTPUT_FILE_RUN" || { echo "Error: Failed to generate run_experiment.sh file."; exit 1; }

chmod +x "$OUTPUT_FILE_RUN" || { echo "Error: Failed to set execute permissions for run_experiment.sh."; exit 1; }

if [ -f "$OUTPUT_FILE_RUN" ]; then
    echo "Successfully created run_experiment.sh: $OUTPUT_FILE_RUN"
else
    echo "Error: Failed to create run_experiment.sh file."
    exit 1
fi

# --- Generate test_boot.sh ---
TEMPLATE_FILE_TEST_BOOT="/data/data/com.termux.nix/files/home/pick-up-nix2/templates/test_boot.sh.template"
OUTPUT_FILE_TEST_BOOT="${TASK_DIR}/test_boot.sh"

sed -e "s|{{TASK_TITLE}}|${TASK_TITLE}|g" \
    -e "s|{{MUSE_NAME}}|${MUSE_NAME}|g" \
    "$TEMPLATE_FILE_TEST_BOOT" > "$OUTPUT_FILE_TEST_BOOT" || { echo "Error: Failed to generate test_boot.sh file."; exit 1; }

chmod +x "$OUTPUT_FILE_TEST_BOOT" || { echo "Error: Failed to set execute permissions for test_boot.sh."; exit 1; }

if [ -f "$OUTPUT_FILE_TEST_BOOT" ]; then
    echo "Successfully created test_boot.sh: $OUTPUT_FILE_TEST_BOOT"
else
    echo "Error: Failed to create test_boot.sh file."
    exit 1
fi


