#!/usr/bin/env bash

# lib_utils.sh: Common utility functions for shell scripts

# Function to log messages
log() {
  echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

log_info() {
  log "[INFO] $1"
}

log_warn() {
  log "[WARN] $1" >&2
}

log_error() {
  log "[ERROR] $1" >&2
  exit 1
}

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}
