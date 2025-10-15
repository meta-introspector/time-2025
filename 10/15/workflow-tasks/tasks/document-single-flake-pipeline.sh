#!/usr/bin/env bash

# SC2154: These variables are referenced but not assigned within the script.
# They are expected to be passed as environment variables by Nix's pkgs.runCommand.
# shellcheck disable=SC2154

set -euo pipefail

FINAL_FLAKE_PATH=""
FINAL_STATUS=""
REPORT_MESSAGE=""

# Check if docs already existed and built successfully
if [ "$(cat "$checkDocStatusResult/status")" = "status=success" ];
then
  FINAL_FLAKE_PATH="$flakePath"
  FINAL_STATUS="docs_already_exist"
  REPORT_MESSAGE="Documentation already existed and built successfully."
elif [ -e "$applyPureDocResult" ];
then # Check if pure application succeeded
  FINAL_FLAKE_PATH="$applyPureDocResult"
  FINAL_STATUS="pure_generation_success"
  REPORT_MESSAGE="Documentation generated and applied purely."
elif [ -e "$applyImpureDocResult" ];
then # Check if impure application succeeded
  FINAL_FLAKE_PATH="$applyImpureDocResult"
  FINAL_STATUS="impure_generation_success"
  REPORT_MESSAGE="Documentation generated and applied impurely (fallback)."
else
  FINAL_FLAKE_PATH="$flakePath" # Output original flake if all else fails
  FINAL_STATUS="generation_failed"
  REPORT_MESSAGE="Documentation generation failed for both pure and impure paths."
fi

# Create a report file
cat > "$out/report.json" <<EOF
{
"flakePath": "$flakePath",
"finalFlakePath": "$FINAL_FLAKE_PATH",
"status": "$FINAL_STATUS",
"message": "$REPORT_MESSAGE"
}
EOF

# Create a symlink to the final flake for convenience
ln -s "$FINAL_FLAKE_PATH" "$out/documented-flake.nix"
echo "hello world"
