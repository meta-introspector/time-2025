#!/usr/bin/env bash

echo "Running nix flake check ./flakes/crq-search/parser and logging output to nix_flake_check_output.log"
nix flake check ./flakes/crq-search/parser &> nix_flake_check_output.log
echo "Done. Check nix_flake_check_output.log for details."
