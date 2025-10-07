#!/usr/bin/env bash

# This script reads ~/.gemini files, encrypts them with sops, and places them
# into a specified sops-secrets directory, generating a corresponding secrets.nix.

set -euo pipefail

GEMINI_HOME="$HOME/.gemini"
SOPS_SECRETS_DIR="./sops-secrets"
SECRETS_NIX_FILE="./secrets.nix"

# Check if sops is installed
if ! command -v sops &> /dev/null
then
    echo "Error: sops command not found. Please install sops (e.g., nix-env -iA nixpkgs.sops)."
    exit 1
fi

# Check if ~/.gemini directory exists
if [ ! -d "$GEMINI_HOME" ]; then
    echo "Error: ~/.gemini directory not found. Please ensure your Gemini CLI is configured."
    exit 1
fi

# Create sops-secrets directory if it doesn't exist
mkdir -p "$SOPS_SECRETS_DIR"

echo "Reading files from $GEMINI_HOME and encrypting with sops..."

# Encrypt oauth_creds.json
if [ -f "$GEMINI_HOME/oauth_creds.json" ]; then
    cp "$GEMINI_HOME/oauth_creds.json" "$SOPS_SECRETS_DIR/oauth_creds.json"
    sops --encrypt --in-place "$SOPS_SECRETS_DIR/oauth_creds.json"
    echo "Encrypted $GEMINI_HOME/oauth_creds.json to $SOPS_SECRETS_DIR/oauth_creds.json"
else
    echo "Warning: $GEMINI_HOME/oauth_creds.json not found. Skipping."
fi

# Encrypt settings.json
if [ -f "$GEMINI_HOME/settings.json" ]; then
    cp "$GEMINI_HOME/settings.json" "$SOPS_SECRETS_DIR/settings.json"
    sops --encrypt --in-place "$SOPS_SECRETS_DIR/settings.json"
    echo "Encrypted $GEMINI_HOME/settings.json to $SOPS_SECRETS_DIR/settings.json"
else
    echo "Warning: $GEMINI_HOME/settings.json not found. Skipping."
fi

# Encrypt google_accounts.json
if [ -f "$GEMINI_HOME/google_accounts.json" ]; then
    cp "$GEMINI_HOME/google_accounts.json" "$SOPS_SECRETS_DIR/google_accounts.json"
    sops --encrypt --in-place "$SOPS_SECRETS_DIR/google_accounts.json"
    echo "Encrypted $GEMINI_HOME/google_accounts.json to $SOPS_SECRETS_DIR/google_accounts.json"
else
    echo "Warning: $GEMINI_HOME/google_accounts.json not found. Skipping."
fi

echo "Generating $SECRETS_NIX_FILE..."

cat <<EOF > "$SECRETS_NIX_FILE"
{ config, lib, pkgs, ... }:

{
  sops.secrets = {
    gemini_oauth_creds = {
      sopsFile = ./sops-secrets/oauth_creds.json;
    };
    gemini_settings = {
      sopsFile = ./sops-secrets/settings.json;
    };
    gemini_google_accounts = {
      sopsFile = ./sops-secrets/google_accounts.json;
    };
  };
}
EOF

echo "Successfully created encrypted secrets in $SOPS_SECRETS_DIR and generated $SECRETS_NIX_FILE."
echo "Remember to add these files to your Git repository (excluding the plain-text originals)."
