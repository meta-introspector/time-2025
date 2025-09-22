#!/usr/bin/env bash

echo "Building template_generator_bin using Nix..."
nix build .#template-generator-bin
echo "Build complete."
