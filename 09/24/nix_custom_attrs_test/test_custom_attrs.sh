#!/usr/bin/env bash
set -euo pipefail

cd nix_custom_attrs_test

echo "--- Testing custom attributes in mypackage.nix ---"

# 1. Build the package (this will also print preBuild hook messages)
echo "Building the package..."
nix-build default.nix --no-out-link

# 2. Query attributes using nix-instantiate and nix-show-derivation
echo -e "\nQuerying attributes using nix-instantiate and nix-show-derivation:"
DRV_PATH=$(nix-instantiate default.nix)
echo "Derivation path: $DRV_PATH"

echo "myCustomTag: $(nix show-derivation \"$DRV_PATH\" | jq -r '.[].env.myCustomTag')"
echo "myVersionOverride: $(nix show-derivation \"$DRV_PATH\" | jq -r '.[].env.myVersionOverride')"
echo "myExtraData (path): $(nix show-derivation \"$DRV_PATH\" | jq -r '.[].env.myExtraData')"

# 3. Query attributes using nix eval (more direct)
echo -e "\nQuerying attributes using nix eval:"
echo "myCustomTag: $(nix eval --raw -f default.nix myCustomTag)"
echo "myVersionOverride: $(nix eval --raw -f default.nix myVersionOverride)"
echo "myExtraData (path): $(nix eval --raw -f default.nix myExtraData)"

# 4. Access attributes from within a nix-shell
echo -e "\nAccessing attributes from within a nix-shell:"
nix-shell default.nix --run 'echo "Inside nix-shell: myCustomTag is $myCustomTag"'
nix-shell default.nix --run 'echo "Inside nix-shell: myVersionOverride is $myVersionOverride"'
nix-shell default.nix --run 'echo "Inside nix-shell: myExtraData is $myExtraData"'

echo -e "\n--- Test complete for mypackage.nix ---"