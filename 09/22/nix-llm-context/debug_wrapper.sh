#!/usr/bin/env bash

# Debug wrapper for generate_monster_group_llm_txt.sh

set -euo pipefail

DEBUG_LOG_FILE=$(mktemp)
echo "--- Debug Wrapper: Arguments Received ---" > "$DEBUG_LOG_FILE"
echo "Number of arguments: $#" >> "$DEBUG_LOG_FILE"
for i in "$@"; do
  echo "Argument $i: $i" >> "$DEBUG_LOG_FILE"
done
echo "-----------------------------------------" >> "$DEBUG_LOG_FILE"
echo "Debug log written to: $DEBUG_LOG_FILE"

# Now execute the actual script
# Assuming generate_monster_group_llm_txt.sh is in the same directory
# and its path is passed as the first argument to this wrapper.
# We need to shift the arguments to pass them correctly to the original script.

# The first argument to this wrapper is the path to generate_monster_group_llm_txt.sh
GENERATOR_SCRIPT="$1"
shift # Remove the first argument (the script path)

# Execute the original script with the remaining arguments
exec "$GENERATOR_SCRIPT" "$@"
