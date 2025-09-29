#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Define the path to the compiled Rust binary
CLI_PATH="./target/debug/streamofrandom_cli"

echo "--- Running QA Plan for streamofrandom_cli ---"

# --- Test Case 1: dev1 ---
echo -e "\n--- Testing 'dev1' subcommand ---"
# We can't easily mock `nix develop` to prevent it from blocking,
# so we'll just check the output and assume `nix` is correctly invoked.
# In a real QA environment, you might mock `nix` or run this in a controlled subshell.
OUTPUT=$(${CLI_PATH} dev1)
if [[ "${OUTPUT}" == *"Entering Nix development shell for pick-up-nix2 and gemini-cli..."* ]]; then
    echo "PASS: dev1 subcommand executed with correct message."
else
    echo "FAIL: dev1 subcommand output incorrect. Expected message not found."
    echo "Output: ${OUTPUT}"
    exit 1
fi

# --- Test Case 2: dev2 ---

echo -e "\n--- Testing 'dev2' subcommand ---"
${CLI_PATH} dev2 || { echo "FAIL: dev2 command failed"; exit 1; }
echo "PASS: dev2 subcommand executed."

# --- Test Case 3: run-task ---

echo -e "\n--- Testing 'run-task' subcommand ---"
# Create a dummy gemini.js for testing purposes
mkdir -p ~/gemini-cli/bundle
echo "console.log('gemini.js called with args:', process.argv.slice(2));" > ~/gemini-cli/bundle/gemini.js
chmod +x ~/gemini-cli/bundle/gemini.js

# Ensure logs directory is clean before test
rm -rf logs

${CLI_PATH} run-task "Test prompt for Gemini" --verbose-output || { echo "FAIL: run-task command failed"; exit 1; }

if [ -d "logs" ]; then
    echo "PASS: 'logs' directory created."
else
    echo "FAIL: 'logs' directory not created."
    exit 1
fi
echo "PASS: run-task subcommand executed."

# Clean up dummy gemini.js
rm ~/gemini-cli/bundle/gemini.js

# --- Test Case 4: today ---

echo -e "\n--- Testing 'today' subcommand ---"
NIX_HOME=$(eval echo ~) # Get actual HOME path
TODAY_DATE=$(date +'%Y/%m/%d')
TODAY_FULL_PATH="${NIX_HOME}/source/github/meta-introspector/streamofrandom/${TODAY_DATE}"
CURRENT_MONTH_PATH="${NIX_HOME}/source/github/meta-introspector/streamofrandom/$(date +'%Y/%m')"
NIX_DIR="${NIX_HOME}/nix"

# Clean up previous symlinks if they exist
rm -f "${NIX_DIR}/current-month" "${NIX_DIR}/today"

OUTPUT=$(${CLI_PATH} today) || { echo "FAIL: today command failed"; exit 1; }

if [ -d "${TODAY_FULL_PATH}" ]; then
    echo "PASS: Today's directory '${TODAY_FULL_PATH}' created."
else
    echo "FAIL: Today's directory '${TODAY_FULL_PATH}' not created."
    exit 1
fi

if [ -L "${NIX_DIR}/current-month" ] && [ "$(readlink "${NIX_DIR}/current-month")" == "${CURRENT_MONTH_PATH}" ]; then
    echo "PASS: Symlink '${NIX_DIR}/current-month' created and points correctly."
else
    echo "FAIL: Symlink '${NIX_DIR}/current-month' not created or points incorrectly."
    exit 1
fi

if [ -L "${NIX_DIR}/today" ] && [ "$(readlink "${NIX_DIR}/today")" == "${TODAY_FULL_PATH}" ]; then
    echo "PASS: Symlink '${NIX_DIR}/today' created and points correctly."
else
    echo "FAIL: Symlink '${NIX_DIR}/today' not created or points incorrectly."
    exit 1
fi

if [[ "${OUTPUT}" == *"${TODAY_FULL_PATH}"* ]]; then
    echo "PASS: Correct path '${TODAY_FULL_PATH}' printed."
else
    echo "FAIL: Incorrect path printed. Expected: '${TODAY_FULL_PATH}', Got: '${OUTPUT}'"
    exit 1
fi

echo "PASS: today subcommand executed."

echo -e "\n--- All tests passed! ---"
