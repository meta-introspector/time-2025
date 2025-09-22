#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="/data/data/com.termux.nix/files/home/pick-up-nix2"
REPORT_ANALYZER_RS_PATH="source/github/meta-introspector/git-submodules-rs-nix/report-analyzer-rs"

echo "--- Building temp-rnix-test with Cargo ---"
# Navigate to the report-analyzer-rs directory and build temp-rnix-test
(
    cd "$PROJECT_ROOT/$REPORT_ANALYZER_RS_PATH"
    cargo build --release --bin temp-rnix-test
)

echo "--- Building report-analyzer-rs with Nix ---"
# Build the Nix flake from the project root, pointing to the flake directory
(
    cd "$PROJECT_ROOT"
    nix build "./$REPORT_ANALYZER_RS_PATH"
)

echo "--- Build process complete ---"