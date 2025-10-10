#!/usr/bin/env bash

set -euo pipefail

FLAKE_SOURCE="$1"
INITIAL_FLAKE_CONTENT_PATH="$2"
GEMINI_CLI_PATH="$3"
out="${out:-/dev/stdout}"

echo "Planning to build derived LLM task flake for: ${FLAKE_SOURCE}" > "$out"
mkdir -p "$out"/derived-flake

# Perform LLM review and attempt to self-improve
echo "--- LLM Self-Improvement during Planning for: ${FLAKE_SOURCE} ---" >> "$out"
echo "Reviewing initial flake.nix with LLM for modifications..." >> "$out"

INITIAL_FLAKE_CONTENT=$(cat "${INITIAL_FLAKE_CONTENT_PATH}")

LLM_PROMPT="Review the following Nix flake. Identify any potential improvements or issues. If you suggest changes, provide the *full, modified flake.nix* content within a markdown code block. Otherwise, state 'NO_MODIFICATIONS'.\n\n'''nix\n${INITIAL_FLAKE_CONTENT}\n'''"

REVIEW_OUTPUT=$(echo "$LLM_PROMPT" | "${GEMINI_CLI_PATH}" --prompt -)
echo "LLM Feedback:" >> "$out"
echo "$REVIEW_OUTPUT" >> "$out"

MODIFIED_FLAKE_CONTENT="${INITIAL_FLAKE_CONTENT}"
# Attempt to extract modified flake.nix from LLM output
# This is a very basic extraction and would need to be more robust for production
if echo "$REVIEW_OUTPUT" | grep -q "\`\`\`nix"; then
  # shellcheck disable=SC2016
  START_PATTERN='\`\`\`nix'
  # shellcheck disable=SC2016
  END_PATTERN='\`\`\`'  MODIFIED_FLAKE_CONTENT=$(echo "$REVIEW_OUTPUT" | awk -v start="$START_PATTERN" -v end="$END_PATTERN" '
    $0 ~ start { p=1; next }
    $0 ~ end { p=0 }
    p
  ')
  echo "LLM suggested modifications. Using modified flake content." >> "$out"
else
  echo "LLM suggested no modifications or format was not recognized. Using original flake content." >> "$out"
fi

echo "${MODIFIED_FLAKE_CONTENT}" > "$out"/derived-flake/flake.nix
echo "nix build $out/derived-flake#defaultPackage.x86_64-linux" > "$out"/build-command.sh
echo "--- LLM Self-Improvement Complete ---" >> "$out"
