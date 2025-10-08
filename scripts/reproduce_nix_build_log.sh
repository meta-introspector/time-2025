#!/usr/bin/env bash

echo "Running nix build ./flakes/crq-search/parser and logging output to nix_build_output.log"
nix build ./flakes/crq-search/parser &> nix_build_output.log
echo "Done. Check nix_build_output.log for details."
