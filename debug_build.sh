#!/usr/bin/env bash

set -euo pipefail

echo "Staging all changes..."
git add .
echo "Changes staged."

echo "Committing changes..."
git commit -m 'Automated debug commit' -a -n # -n to skip pre-commit hooks
echo "Changes committed."

echo "Pushing changes..."
git push
echo "Changes pushed."

echo "Deleting all flake.lock files..."
find . -name "flake.lock" -delete
echo "All flake.lock files deleted."

echo "Running nix flake update..."
nix flake update
echo "nix flake update completed."

echo "Attempting to build bootstrap.zos..."
nix build /data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/10/15/zos#packages.aarch64-linux.bootstrap.zos
echo "Build attempt completed."