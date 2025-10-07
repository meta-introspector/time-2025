#!/usr/bin/env bash

# Default values
OUTPUT_FILE="sources.txt"
TARGET_FILE="telemetry.log"
SEARCH_PATHS=()

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -o|--output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        -t|--target)
            TARGET_FILE="$2"
            shift 2
            ;;
        *)
            SEARCH_PATHS+=("$1")
            shift
            ;;
    esac
done

# If no search paths are provided, use default ones
if [ ${#SEARCH_PATHS[@]} -eq 0 ]; then
    SEARCH_PATHS+=("$HOME/gemini-cli/.gemini/")
    SEARCH_PATHS+=("../../")
fi

# Find and output
for path in "${SEARCH_PATHS[@]}"; do
    find "$path" -name "$TARGET_FILE"
done > "$OUTPUT_FILE"
