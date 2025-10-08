#!/bin/bash

FILE_TELEMETRY="/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/27/7-concepts/6-qa-testing/tests/consolidated-impure-gemini-telemetry/flake.nix"

# 1. Add homeDirCreds as an input
sed -i '/mycologyContext = { }; # Optional input for mycology framework context/a\n    homeDirCreds.url = "path:../../flakes/feature-3-home-dir-creds";' "$FILE_TELEMETRY"

# 2. Modify buildPhase to use geminiCliWithHomeCreds and remove hardcoded cp commands
# This is a multi-line replacement. I will target the block of cp commands.
sed -i '/cp /data/data/com.termux.nix/files/home/.gemini/settings.json $HOME/.gemini/,/cp /data/data/com.termux.nix/files/home/.gemini/google_accounts.json $HOME/.gemini/c\
            # Credentials are now handled by homeDirCreds flake\n            # The geminiCliWithHomeCreds wrapper will set up HOME correctly\n' "$FILE_TELEMETRY"

# 3. Modify the Gemini CLI call to use the wrapper
sed -i 's@exec ${gemini-cli.packages.${system}.default}/bin/gemini-cli "$@"@exec ${homeDirCreds.packages.${system}.default}/bin/gemini-cli-with-home-creds "$@"@g' "$FILE_TELEMETRY"

echo "Consolidated telemetry flake updated for homeDirCreds integration."
