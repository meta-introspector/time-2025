#!/usr/bin/env bash

set -euo pipefail

FLAKE_PATH="/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/10/12/audit-flakes/001_collect_locks"

echo "Evaluating outputs of 001_collect_locks flake for aarch64-linux system..."
nix eval --json --impure --expr "(builtins.getFlake \"path:${FLAKE_PATH}\").outputs.aarch64-linux"
