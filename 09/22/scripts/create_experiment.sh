#!/usr/bin/env bash

# This script creates a new experimental project directory according to CRQ-031.

set -euo pipefail

# Source lib_search_utils.sh for get_project_root and ensure_output_dir_exists
# Assuming lib_search_utils.sh is in the same directory or a known path
# For now, I'll define them inline for simplicity, but ideally, it should be sourced.

# Function to get the project root (simplified for this context)
get_project_root() {
  git rev-parse --show-toplevel
}

# Function to ensure a directory exists
ensure_output_dir_exists() {
  local dir_path="$1"
  mkdir -p "$dir_path"
}

PROJECT_NAME="$1"

if [ -z "$PROJECT_NAME" ]; then
  echo "Usage: $0 <project_name>"
  exit 1
fi

PROJECT_ROOT=$(get_project_root)

# Get current date for YYYY/MM/DD structure
YEAR=$(date +%Y)
MONTH=$(date +%m)
DAY=$(date +%d)

EXPERIMENT_BASE_DIR="$PROJECT_ROOT/source/github/meta-introspector/streamofrandom/$YEAR/$MONTH/$DAY"
EXPERIMENT_DIR="$EXPERIMENT_BASE_DIR/$PROJECT_NAME"
AUDIT_LOG="$PROJECT_ROOT/logs/experiment_creation_audit.log"

ensure_output_dir_exists "$EXPERIMENT_DIR"
ensure_output_dir_exists "$(dirname "$AUDIT_LOG")"

TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
USER_AGENT="$(whoami)" # Or a more sophisticated way to identify the agent

echo "$TIMESTAMP | Experiment: $PROJECT_NAME | Path: $EXPERIMENT_DIR | Created by: $USER_AGENT" >> "$AUDIT_LOG"

echo "Experimental project '$PROJECT_NAME' created at: $EXPERIMENT_DIR"
echo "Audit log updated: $AUDIT_LOG"
