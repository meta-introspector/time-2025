#!/bin/bash

# Define the path to the gemini_runner_flake
FLAKE_DIR="/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/27/gemini_runner_flake"

# Define the prompt for Gemini
PROMPT="Hello from inside nix"

# Define the logs directory
LOGS_DIR="/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/27/logs"

# Generate a timestamp for the log file
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="$LOGS_DIR/gemini_response_$TIMESTAMP.log"

echo "Running gemini-cli with prompt: \"$PROMPT\""
echo "Output will be logged to: $LOG_FILE"

# Run the gemini_runner_flake with the prompt and redirect output to the log file
# We use '2>&1' to redirect stderr to stdout, so both are captured in the log file.
if nix run --impure "$FLAKE_DIR" -- "$PROMPT" > "$LOG_FILE" 2>&1; then
    echo "Gemini-cli execution completed successfully. Check $LOG_FILE for output."
else
    echo "Gemini-cli execution failed. Check $LOG_FILE for errors."
fi
