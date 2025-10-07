#!/usr/bin/env bash
# evaluate-nix-expression.sh: Evaluates a Nix expression with provided arguments.
#
# This script takes paths to nixpkgs, a Nix library, and a commit message file
# as arguments, evaluates a specific Nix expression, and prints the JSON result.
#
# Usage: ./evaluate-nix-expression.sh --nixpkgs-path <path> --crq-check-lib-path <path> --commit-msg-file <path>

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
    *) # Catch all remaining arguments as unknown options or positional arguments
      echo "Unknown option or unexpected argument: $i" >&2
      exit 1
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
# This script expects to be run in an environment where nix is available
# (e.g., via buildInputs in a Nix derivation).

# The actual Nix expression to evaluate
NIX_EXPR="let pkgs = import \"$NIXPKGS_PATH\" {}; in import \"$CRQ_CHECK_LIB_PATH\" { inherit pkgs; commitMsgFile = \"$COMMIT_MSG_FILE\"; }"

if [ "$DEBUG" = true ]; then
  echo "[DEBUG] Evaluating Nix expression: $NIX_EXPR" >&2
fi

# Execute nix eval and print the JSON output
nix eval --json --expr "$NIX_EXPR"
