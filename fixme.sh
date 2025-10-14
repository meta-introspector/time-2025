#!/usr/bin/env bash

# This script attempts to build a flake without using the '--flake' flag,
# to test implicit flake detection in the current Nix environment.

# Ensure experimental features are enabled for the current shell session
export NIX_CONFIG="experimental-features = nix-command flakes"

printf "Attempting to build test-env-var/flake.nix without '--flake' flag...\n"

if ! nix build --extra-experimental-features 'nix-command flakes' /data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/10/12/audit-flakes/test-env-var#default; then
  printf "\nBuilding the flake without '--flake' failed. This indicates that the current Nix installation does not support implicit flake detection or requires the '--flake' flag, which is not recognized.\n"
  printf "Please consider updating Nix to version 2.4 or newer and ensuring experimental features are properly enabled.\n"
else
  printf "\nThe 'nix build' command succeeded. This means implicit flake detection is working.\n"
fi
