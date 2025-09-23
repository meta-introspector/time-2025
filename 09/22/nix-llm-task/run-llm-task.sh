#!/usr/bin/env bash

set -euo pipefail

# Define the NAR file to fetch
NAR_TO_FETCH="llm-context-OEIS-latest.nar" # Example NAR file, adjust as needed

echo "Starting LLM task with NAR data..."

# Step 1 & 2: Fetching and unpacking NAR file
# This assumes 'fetch-nar-data-wrapper.sh' is in the PATH, e.g., from a devShell
echo "Fetching and unpacking NAR file: ${NAR_TO_FETCH}"
fetch-nar-data-wrapper.sh "${NAR_TO_FETCH}"

UNPACKED_DATA_DIR="./unpacked-nar-data"

if [[ ! -d "$UNPACKED_DATA_DIR" ]]; then
  echo "Error: Unpacked data directory not found: ${UNPACKED_DATA_DIR}"
  exit 1
fi

# Step 3: Load the data
# Assuming the NAR contains a single text file, or we know the path to the relevant file
DATA_FILE="${UNPACKED_DATA_DIR}/llm-context-OEIS-latest.txt" # Adjust based on actual NAR content

if [[ ! -f "$DATA_FILE" ]]; then
  echo "Error: Data file not found in unpacked NAR: ${DATA_FILE}"
  exit 1
fi

LLM_CONTEXT=$(cat "${DATA_FILE}")

echo "Loaded LLM context from NAR file. First 100 characters:"
echo "${LLM_CONTEXT:0:100}..."

# Step 4: Construct a prompt for Gemini
GEMINI_PROMPT="Using the following context, provide a creative and esoteric interpretation of numbers:\n\n${LLM_CONTEXT}\n\nInterpretation:"

echo "Generated Gemini Prompt (first 200 chars):"
echo "${GEMINI_PROMPT:0:200}..."

# Step 5: Execute the Gemini LLM task using the nix run pattern from gemini_cli_new.sh
echo "Executing Gemini LLM task:"
nix run "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify#gemini-cli" -- --prompt "${GEMINI_PROMPT}"

echo "LLM task completed."
