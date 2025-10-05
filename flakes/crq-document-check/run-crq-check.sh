#!/usr/bin/env bash
# run-crq-check.sh: Evaluates a Nix expression for CRQ document existence.
#
# This script takes paths to nixpkgs, the CRQ check library, and a commit message file
# as arguments, evaluates the CRQ check Nix expression, and outputs a JSON result.
#
# Usage: ./run-crq-check.sh --nixpkgs-path <path> --crq-check-lib-path <path> --commit-msg-file <path>

set -euo pipefail

# --- Configuration and Defaults ---
NIXPKGS_PATH=""
CRQ_CHECK_LIB_PATH=""
COMMIT_MSG_FILE=""
DEBUG=false

# --- Argument Parsing ---
for i in "$@"; do
  case $i in
    --nixpkgs-path=*)
      NIXPKGS_PATH="${i#*=}"
      shift # past argument=value
      ;;
    --crq-check-lib-path=*)
      CRQ_CHECK_LIB_PATH="${i#*=}"
      shift # past argument=value
      ;;
    --commit-msg-file=*)
      COMMIT_MSG_FILE="${i#*=}"
      shift # past argument=value
      ;;
    --debug)
      DEBUG=true
      shift # past argument with no value
      ;;
    *)
      # positional argument, not expected for now
      ;;
  esac
done

# --- Validation ---
if [ -z "$NIXPKGS_PATH" ]; then
  echo "Error: --nixpkgs-path is required." >&2
  exit 1
fi
if [ -z "$CRQ_CHECK_LIB_PATH" ]; then
  echo "Error: --crq-check-lib-path is required." >&2
  exit 1
fi
if [ -z "$COMMIT_MSG_FILE" ]; then
  echo "Error: --commit-msg-file is required." >&2
  exit 1
fi

# --- Debugging Output ---
if [ "$DEBUG" = true ]; then
  echo "[DEBUG] NIXPKGS_PATH: $NIXPKGS_PATH" >&2
  echo "[DEBUG] CRQ_CHECK_LIB_PATH: $CRQ_CHECK_LIB_PATH" >&2
  echo "[DEBUG] COMMIT_MSG_FILE: $COMMIT_MSG_FILE" >&2
fi

# --- Nix Evaluation ---
# Ensure nix and jq are available in PATH for this script
# This script expects to be run in an environment where nix and jq are available
# (e.g., via buildInputs in a Nix derivation).

NIX_OUTPUT=$(nix eval --json --arg pkgs "$NIXPKGS_PATH" --arg crqCheckLib "$CRQ_CHECK_LIB_PATH" --argstr commitMsgFile "$COMMIT_MSG_FILE" --expr 'let pkgs = import pkgs {}; in import crqCheckLib { inherit pkgs; commitMsgFile = commitMsgFile; }')

if [ "$DEBUG" = true ]; then
  echo "[DEBUG] NIX_OUTPUT: $NIX_OUTPUT" >&2
fi

# --- Parse and Output Result ---
SUCCESS=$(echo "$NIX_OUTPUT" | jq -r '.success')
MESSAGE=$(echo "$NIX_OUTPUT" | jq -r '.message')

if [ "$DEBUG" = true ]; then
  echo "[DEBUG] SUCCESS: $SUCCESS" >&2
  echo "[DEBUG] MESSAGE: $MESSAGE" >&2
fi

if [ "$SUCCESS" = "false" ]; then
  echo "$MESSAGE" >&2
  exit 1
else
  exit 0
fi