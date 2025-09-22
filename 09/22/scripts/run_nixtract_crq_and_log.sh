#!/usr/bin/env bash

# This script runs the launch_crq_session.sh for nixtract and captures its output to a log file.

set -euo pipefail

LOG_DIR="./logs"
mkdir -p "$LOG_DIR"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="${LOG_DIR}/nixtract_crq_launch_${TIMESTAMP}.log"

echo "Running launch_crq_session.sh for nixtract and logging output to ${LOG_FILE}"

bash ./scripts/launch_crq_session.sh vendor/nix/nixtract 001 &> "${LOG_FILE}"

echo "Script finished. Check ${LOG_FILE} for output."
