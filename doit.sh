#!/usr/bin/env bash

set -euo pipefail

FLAKE_AUDITOR_DIR="/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/10/14/flake_auditor"

cd "$FLAKE_AUDITOR_DIR"

echo "Testing nix develop environment for flake_auditor..."

nix develop -vvvvv --command bash -c "rustc --version && cargo --version && echo 'Nix develop environment test successful!'"

echo "doit.sh finished."
