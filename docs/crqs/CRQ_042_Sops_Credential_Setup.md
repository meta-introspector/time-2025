# CRQ-042: Secure Credential Setup with sops-nix

## 1. Title
Secure Credential Setup with sops-nix for Gemini CLI

## 2. Description
This CRQ outlines the process for securely setting up and managing Gemini CLI credentials using `sops-nix`. This involves generating a GPG key, configuring `sops`, and using a provided script to encrypt existing `~/.gemini` files into `sops`-managed secrets within the project.

## 3. Dependencies
*   `gnupg` installed and available in the development environment (added to `devShell` in `flake.nix`).
*   `sops` installed and available.
*   `create_gemini_sops_secrets.sh` script available and executable.
*   `Makefile` with `setup-sops` target available.

## 4. Steps

### Step 4.1: Generate a GPG Key (Manual User Action)
1.  Open your terminal and enter the Nix development shell: `nix develop`
2.  Generate a GPG key by running: `gpg --full-generate-key`
3.  Follow the prompts to create your key. Choose a strong passphrase.
4.  List your secret keys to get the long form of your key ID: `gpg --list-secret-keys --keyid-format LONG`
5.  Note down your GPG key ID (e.g., `sec   rsa4096/XXXXXXXXXXXXXXXX 2023-01-01 [SC]`).

### Step 4.2: Configure sops with a `.sops.yaml` file (Manual User Action)
1.  In the root of your project (`/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/`), create a file named `.sops.yaml`.
2.  Add the following content to `.sops.yaml`, replacing `YOUR_GPG_KEY_ID` with the long form of your GPG key ID from Step 4.1:

    ```yaml
    keys:
      - &main_key 0xYOUR_GPG_KEY_ID
    creation_rules:
      - path_regex: .*/sops-secrets/.*\\.json$$
        pgp: *main_key
    ```

### Step 4.3: Encrypt Gemini CLI Credentials
1.  Navigate to the directory where you want the `sops-secrets/` directory and `secrets.nix` file to be created (e.g., the root of a flake that uses these secrets).
2.  Run the `Makefile` target: `make setup-sops`
    *   This will execute the `create_gemini_sops_secrets.sh` script, which will:
        *   Read `oauth_creds.json`, `settings.json`, and `google_accounts.json` from your `~/.gemini` directory.
        *   Encrypt each found file using `sops` and place the encrypted versions in a `sops-secrets/` subdirectory.
        *   Generate a `secrets.nix` file that references these encrypted secrets.

## 5. Acceptance Criteria
*   A GPG key is successfully generated and configured for `sops`.
*   A `.sops.yaml` file is present in the project root, correctly configured with the GPG key ID.
*   The `sops-secrets/` directory contains encrypted versions of `oauth_creds.json`, `settings.json`, and `google_accounts.json` (if they existed in `~/.gemini`).
*   A `secrets.nix` file is generated, correctly referencing the encrypted secrets.
*   Nix flakes that have been refactored to use `sops-nix` (e.g., the `gemini-cli` related flakes and `rust_knowledge_extractor`) can successfully build and access the decrypted credentials during their build phase.
*   The `create_gemini_sops_secrets.sh` script executes without errors.

## 6. Verification
1.  After completing Step 4.3, attempt to build one of the refactored flakes (e.g., `nix build .#packages.default` from the `streamofrandom/2025` directory).
2.  Check the build logs for messages indicating successful credential access (e.g., "Credentials copied from decryptedSopsSecrets to $HOME/.gemini/").
3.  Verify that `gemini-cli` (or other tools) within the build can successfully make API calls if applicable.
