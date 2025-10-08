#!/bin/bash

FILE_TELEMETRY="/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/27/7-concepts/6-qa-testing/tests/consolidated-impure-gemini-telemetry/flake.nix"

sed -i 's@^\s*if \[ -d "\${credsSourceDir}" \]; then@        # if [ -d "${credsSourceDir}" ]; then@g' "$FILE_TELEMETRY"
sed -i 's@^\s*cp -r \${credsSourceDir}/\* creds/@        # cp -r ${credsSourceDir}/* creds/@g' "$FILE_TELEMETRY"

echo "Commented out credsSourceDir usage."