#!/usr/bin/env bash

set -e

# This wrapper script runs statix check on each file provided as an argument.
# It is used to work around statix's limitation with multiple file arguments
# when invoked by pre-commit.

EXIT_CODE=0

for file in "$@"; do
  echo "Running statix check on $file..."
  if ! statix check "$file"; then
    echo "Statix check failed for $file."
    EXIT_CODE=1
  fi
done

exit $EXIT_CODE
