#!/usr/bin/env bash

# This script pushes the current branch of the main repository to its origin.
# It is a wrapper around 'git push origin HEAD' to adhere to the scripting standard.

set -e

echo "Pushing current branch to origin..."
git push origin HEAD

echo "Push completed."
