#!/usr/bin/env bash

echo "Building template_generator_bin within a Nix development shell..."
nix develop --command bash -c "cargo build --release -p template_generator_bin"
echo "Build command executed."
