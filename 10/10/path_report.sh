#!/usr/bin/env bash

echo "--- Report for 'path:' instances in .nix files ---"
find . -name "*.nix" -exec sh -c 'grep -F "path:" "$0"' {} \; -print
echo ""
