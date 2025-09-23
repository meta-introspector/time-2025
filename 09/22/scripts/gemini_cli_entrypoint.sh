#!/usr/bin/env bash

# Function to log messages
log() {
  echo "[INFO] $1"
}

# Function to log errors
error() {
  echo "[ERROR] $1" >&2
  exit 1
}

PROJECT_ROOT="/data/data/com.termux.nix/files/home/pick-up-nix"
GEMINI_CLI_DIR="$PROJECT_ROOT/vendor/external/gemini-cli"

log "Inside rust-nix devShell."
log "Entering gemini-cli devShell..."

cd "$GEMINI_CLI_DIR" || error "Failed to change directory to $GEMINI_CLI_DIR"

log "Inside gemini-cli devShell."
log "Launching gemini..."

gemini

log "Exiting gemini-cli devShell."
