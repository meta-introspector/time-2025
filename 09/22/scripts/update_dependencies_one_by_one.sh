#!/usr/bin/env bash

set -euo pipefail

# This script updates the dependencies one by one, with a confirmation step.

INPUT_FILE="index/dependency_update_list.txt"

if [ ! -f "$INPUT_FILE" ]; then
  echo "Dependency list not found. Please run generate_dependency_list.sh first."
  exit 1
fi

while IFS= read -r dep; do
  read -p "Update dependency '$dep'? (y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Updating dependency: $dep"
    nix flake lock --update-input "$dep"
  fi
done < "$INPUT_FILE"
