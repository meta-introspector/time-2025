#!/bin/bash

TASK_FILE="$1"

if [ -z "$TASK_FILE" ]; then
  echo "Usage: $0 <task_file>"
  exit 1
fi

if [ ! -f "$TASK_FILE" ]; then
  echo "Error: Task file '$TASK_FILE' not found."
  exit 1
fi

# Determine Gemini CLI invocation method (bunx or npx)
GEMINI_INVOCATION="gemini"
if command -v bun &> /dev/null; then
  GEMINI_INVOCATION="bunx @google/gemini-cli"
elif command -v npx &> /dev/null; then
  GEMINI_INVOCATION="npx @google/gemini-cli"
fi

# Construct the full Gemini command
# Using --prompt-interactive to continue the session after loading the task file
GEMINI_COMMAND="$GEMINI_INVOCATION --model=gemini-2.5-flash --prompt-interactive \"@$TASK_FILE\""

# Call subtask.sh to launch this command in a new split window
# Use absolute path for subtask.sh
/data/data/com.termux.nix/files/home/pick-up-nix/subtask.sh "$GEMINI_COMMAND"