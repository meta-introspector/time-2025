#!/usr/bin/env bash

set -euo pipefail

# Ensure gpg-agent is running and passphrase is cached.
# This script assumes that 'sops' and 'nix' commands are available in the PATH.

# --- Configuration ---
SOPS_SECRETS_DIR="./sops-secrets"
WRAP_GEMINI_FLAKE_PATH="./flakes/wrap-gemini-secrets"

# --- Functions ---
cleanup() {
  if [ -n "$DECRYPTED_SECRETS_TMPDIR" ] && [ -d "$DECRYPTED_SECRETS_TMPDIR" ]; then
    echo "Cleaning up temporary decrypted secrets in $DECRYPTED_SECRETS_TMPDIR..."
    rm -rf "$DECRYPTED_SECRETS_TMPDIR"
  fi
}

# Register the cleanup function to be called on EXIT
trap cleanup EXIT

# --- Main Logic ---

# 1. Create a temporary directory for decrypted secrets
DECRYPTED_SECRETS_TMPDIR=$(mktemp -d)
echo "Decrypting secrets to temporary directory: $DECRYPTED_SECRETS_TMPDIR"

# 2. Decrypt secrets
sops -d "$SOPS_SECRETS_DIR/oauth_creds.json" > "$DECRYPTED_SECRETS_TMPDIR/oauth_creds.json"
sops -d "$SOPS_SECRETS_DIR/settings.json" > "$DECRYPTED_SECRETS_TMPDIR/settings.json"
sops -d "$SOPS_SECRETS_DIR/google_accounts.json" > "$DECRYPTED_SECRETS_TMPDIR/google_accounts.json"

# 3. Build geminiCliWithSecrets package
echo "Building geminiCliWithSecrets package..."
GEMINI_CLI_WITH_SECRETS_PATH=$(nix build --no-link --print-out-paths "$WRAP_GEMINI_FLAKE_PATH"#packages.aarch64-linux.geminiCliWithSecrets)

# 4. Run gemini-cli-with-secrets
echo "Running gemini-cli-with-secrets..."
"$GEMINI_CLI_WITH_SECRETS_PATH"/bin/gemini-cli-with-secrets "$DECRYPTED_SECRETS_TMPDIR" "$@"

echo "--- gemini-cli execution complete ---"
