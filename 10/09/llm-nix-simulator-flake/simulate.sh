#!/usr/bin/env bash
set -euo pipefail

# Read the prompt from the file passed as an argument
PROMPT_FILE="$1"
FULL_PROMPT=$(cat "$PROMPT_FILE")

# Call the LLM API wrapper
# Assuming llmApiWrapper provides a binary like 'call-llm-api'
# and it takes the prompt as an argument and outputs JSON
"${LLM_API_WRAPPER_BIN}" "$FULL_PROMPT" > "$2/simulated-output.json"

echo "Nix simulation results saved to $2/simulated-output.json"