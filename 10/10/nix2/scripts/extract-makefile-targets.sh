#!/usr/bin/env bash

# Script to extract Makefile targets and their first command line.
# Usage: extract-makefile-targets.sh <Makefile_path>

MAKEFILE_PATH="$1"

if [ -z "$MAKEFILE_PATH" ]; then
  echo "Usage: $0 <Makefile_path>" >&2
  exit 1
fi

if [ ! -f "$MAKEFILE_PATH" ]; then
  echo "Error: Makefile not found at $MAKEFILE_PATH" >&2
  exit 1
fi

# Initialize JSON array
JSON_OUTPUT="["

# Read the Makefile line by line
while IFS= read -r line; do
  # Check if the line defines a target (e.g., 'target: dependencies')
  if [[ "$line" =~ ^([a-zA-Z0-9_-]+):.*$ ]]; then
    TARGET="${BASH_REMATCH[1]}"
    # Read the next line, which should be the command (starts with a tab)
    IFS= read -r command_line
    if [[ "$command_line" =~ ^\t(.*)$ ]]; then
      COMMAND="${BASH_REMATCH[1]}"
      # Escape double quotes and backslashes for JSON
      ESCAPED_TARGET=$(echo "$TARGET" | sed 's/"/\\"/g' | sed 's/\\/\\\\/g')
      ESCAPED_COMMAND=$(echo "$COMMAND" | sed 's/"/\\"/g' | sed 's/\\/\\\\/g')

      # Append to JSON output
      if [ "$JSON_OUTPUT" != "[" ]; then
        JSON_OUTPUT+=,
      fi
      JSON_OUTPUT+="{\"target\":\"$ESCAPED_TARGET\",\"command\":\"$ESCAPED_COMMAND\"}"
    fi
  fi
done < "$MAKEFILE_PATH"

JSON_OUTPUT+="]"

echo "$JSON_OUTPUT"
