#!/bin/bash

FILE_TELEMETRY="/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/27/7-concepts/6-qa-testing/tests/consolidated-impure-gemini-telemetry/flake.nix"

# 1. Comment out credsSourceDir argument in outputs function
sed -i 's!\(outputs = { self, nixpkgs, flake-utils, gemini-cli, \)credsSourceDir ? "[^"]*", \(filePath ? null } @ inputs:\)!\1# credsSourceDir ? "/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/time-2025/09/27/7-concepts/creds", \2!g' "$FILE_TELEMETRY"

# 2. Comment out credsSourceDir usage in buildPhase (if/cp commands)
sed -i 's@^\s*if \[ -d "\${credsSourceDir}" \]; then@        # if [ -d "${credsSourceDir}" ]; then@g' "$FILE_TELEMETRY"
sed -i 's@^\s*cp -r \${credsSourceDir}/\* creds/@        # cp -r ${credsSourceDir}/* creds/@g' "$FILE_TELEMETRY"

echo "Commented out credsSourceDir usages."