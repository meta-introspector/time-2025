#!/usr/bin/env bash

# This script creates the directory structure for the bootstrap lattice within the
# source/github/meta-introspector/bootstrap submodule.

set -e

BOOTSTRAP_ROOT="/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/bootstrap"

# Define the prime number layers
PRIME_LAYERS=(0 1 2 3 5 7 11 13 17 19)

echo "Creating bootstrap lattice directories under: $BOOTSTRAP_ROOT"

for layer in "${PRIME_LAYERS[@]}"; do
    LAYER_DIR="${BOOTSTRAP_ROOT}/layer_${layer}"
    echo "Creating directory: $LAYER_DIR"
    mkdir -p "$LAYER_DIR"
done

echo "Bootstrap lattice directory creation completed."
