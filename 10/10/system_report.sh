#!/usr/bin/env bash

echo "--- Report for 'system' (excluding ${system}) ---"
find . -name "*.nix" -exec sh -c 'grep -E "system" "$0" | grep -v '\$\{system\}'' {} \; -print
echo ""

echo "--- Report for 'aarch' ---"
find . -name "*.nix" -exec sh -c 'grep -E "aarch" "$0"' {} \; -print
echo ""

echo "--- Report for 'x86' ---"
find . -name "*.nix" -exec sh -c "grep -F 'system = \"x86_64-linux\";' \"$0\"" {} \; -print
echo ""
