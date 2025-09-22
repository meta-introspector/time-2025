#!/bin/bash

# lib_utils.sh: Common utility functions for shell scripts

log_info() {
  echo "[INFO] $1"
}

log_warn() {
  echo "[WARN] $1" >&2
}

log_error() {
  echo "[ERROR] $1" >&2
  exit 1
}
