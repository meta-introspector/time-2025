#!/usr/bin/env bash

# This script updates the flake.lock file for the 001_collect_locks flake.

#nix flake update /data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/10/12/audit-flakes/001_collect_locks --extra-experimental-features 'nix-command flakes'


if ! nix flake update -vvvvvvv /data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/10/12/audit-flakes/001_collect_locks --extra-experimental-features 'nix-command flakes'; then
  echo "Error: Failed to update flake.lock for 001_collect_locks."
  exit 1
else
  echo "Successfully updated flake.lock for 001_collect_locks."
fi
