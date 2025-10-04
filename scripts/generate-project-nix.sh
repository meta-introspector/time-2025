#!/usr/bin/env bash

# scripts/generate-project-nix.sh
#
# This script is responsible for generating the `project.nix` file in the project root.
# The `project.nix` file is a dynamically generated Nix expression that represents
# a nested attribute set of all `.nix` files found within the project directory.
#
# It leverages the `lib/generate-project-nix.nix` module to perform the recursive scanning
# and evaluation of `.nix` files. The output of the Nix evaluation is then redirected
# to `project.nix`.
#
# This generated `project.nix` serves as a single entry point for accessing and
# analyzing all Nix code in the project, facilitating tasks like project-wide QA checks,
# indexing, and meta-introspection.

set -euo pipefail

# Define the output file name
OUTPUT_FILE="project.nix"

# Generate the project.nix file using nix-instantiate.
# The --eval flag evaluates the expression.
# The --strict flag ensures all variables are defined.
# The --expr flag specifies the Nix expression to evaluate.
# We import the `lib/generate-project-nix.nix` module and call its top-level function
# with the current directory (`./.`) as the `path` argument, converted to a string.
# The output of this evaluation (the nested attribute set) is then redirected to OUTPUT_FILE.
nix-instantiate --eval --strict --expr 'import ./lib/generate-project-nix.nix {} { path = toString ./.; }' > "$OUTPUT_FILE"

echo "Generated $OUTPUT_FILE"
