#!/usr/bin/env bash

LOG_FILE="nix_build.log"

echo "Starting Nix build at $(date)" > "$LOG_FILE"
nix develop --command ./build_project.sh 2>&1 | tee -a "$LOG_FILE"
echo "Nix build finished at $(date)" >> "$LOG_FILE"
