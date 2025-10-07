#!/usr/bin/env bash

echo "Running strace for nix flake check ./flakes/crq-search/parser, output to nix_flake_check_strace.log"
strace -o nix_flake_check_strace.log nix flake check ./flakes/crq-search/parser
echo "Done. Check nix_flake_check_strace.log for details."
