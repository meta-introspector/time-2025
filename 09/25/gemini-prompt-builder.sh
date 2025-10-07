#!/usr/bin/env bash

set -euxo pipefail # Added -x for tracing

# Arguments passed from Nix
# $1: out path
# $2: prompt
# $3: gemini-cli package path

OUT_PATH="$1"
PROMPT="$2"
GEMINI_CLI_PACKAGE="$3"

mkdir -p "$OUT_PATH"/telemetry

# Write the original prompt to a file
echo "${PROMPT}" > "$OUT_PATH"/original_prompt.txt

# Write the prompt to a temporary file for gemini-cli
PROMPT_FILE=$(mktemp)
echo "${PROMPT}" > "$PROMPT_FILE"

# Set HOME to a writable temporary directory for gemini-cli
TEMP_HOME=$(mktemp -d)
export HOME="$TEMP_HOME"
trap 'rm -rf "$HOME"' EXIT # Clean up the temporary HOME directory on exit

# Create ~/.gemini directory
mkdir -p "$HOME/.gemini"

# Copy actual credential files from host system
cp /data/data/com.termux.nix/files/home/.gemini/settings.json "$HOME/.gemini/"
cp /data/data/com.termux.nix/files/home/.gemini/oauth_creds.json "$HOME/.gemini/"
cp /data/data/com.termux.nix/files/home/.gemini/google_accounts.json "$HOME/.gemini/"
echo "✅ Copied credential files from host ~/.gemini/ to $HOME/.gemini/"

# Run gemini with the prompt from the temporary file and capture its output

# Run gemini with the prompt from the temporary file and capture its output
# Capture stdout and stderr to gemini_output.txt
echo "DEBUG: Invoking gemini: \"$GEMINI_CLI_PACKAGE\"/bin/gemini --prompt-file \"$PROMPT_FILE\""
"$GEMINI_CLI_PACKAGE"/bin/gemini --prompt-file "$PROMPT_FILE" > "$OUT_PATH"/gemini_output.txt 2>&1
GEMINI_EXIT_CODE=$? # Capture exit code
echo "DEBUG: gemini exit code: $GEMINI_EXIT_CODE"

# Clean up the temporary file
rm "$PROMPT_FILE"

# Get the current timestamp
TIMESTAMP=$(date -uIs)

# Create a telemetry summary JSON using shell variables
cat > "$OUT_PATH"/telemetry/summary.json << EOF
{
  "prompt": "${PROMPT}",
  "gemini_output_file": "gemini_output.txt",
  "gemini_exit_code": ${GEMINI_EXIT_CODE},
  "timestamp": "${TIMESTAMP}"
}
EOF
