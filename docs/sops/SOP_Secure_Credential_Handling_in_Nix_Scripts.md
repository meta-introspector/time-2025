# SOP: Secure Credential Handling in Nix Scripts using sops-nix

## 1. Purpose

This Standard Operating Procedure (SOP) outlines the process for securely managing sensitive credentials (e.g., API keys, OAuth tokens) within Nix flakes and derivations using `sops-nix`. This ensures that credentials are encrypted in the repository, decrypted only when necessary during Nix builds, and never hardcoded or exposed in plain text.

## 2. Scope

This SOP applies to all Nix flakes and derivations within the project that require access to sensitive credentials, such as `oauth_creds.json`, `settings.json`, and `google_accounts.json` for `gemini-cli` interactions.

## 3. Prerequisites

*   **sops-nix setup:** Ensure `sops-nix` is properly configured in your development environment, including GPG keys for encryption/decryption.
*   **sops-nix input in flake:** All relevant flakes must include `sops-nix` as an input:
    ```nix
    inputs = {
      # ... other inputs
      sops-nix.url = "github:meta-introspector/sops-nix?ref=feature/working-gemini-cli-nix-store";
    };
    ```

## 4. Procedure

### 4.1. Encrypting Credentials with sops

1.  **Create a `sops-secrets/` directory:** In the same directory as your `flake.nix`, create a subdirectory named `sops-secrets/`.
    ```bash
    mkdir -p sops-secrets/
    ```
2.  **Place sensitive files:** Move your sensitive credential files (e.g., `oauth_creds.json`, `settings.json`, `google_accounts.json`) into the `sops-secrets/` directory.
3.  **Encrypt files:** Use the `sops` command-line tool to encrypt each sensitive file.
    ```bash
    sops --encrypt --in-place sops-secrets/oauth_creds.json
    sops --encrypt --in-place sops-secrets/settings.json
    sops --encrypt --in-place sops-secrets/google_accounts.json
    ```
    *   **Note:** Ensure your GPG key is available for `sops` to perform the encryption.

### 4.2. Defining Secrets in `secrets.nix`

1.  **Create `secrets.nix`:** In the same directory as your `flake.nix`, create a file named `secrets.nix` with the following structure:
    ```nix
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
    ```

### 4.3. Integrating Decrypted Secrets into Nix Derivations

1.  **Import `secrets.nix` and define `decryptedSopsSecrets` derivation:**
    Within your `flake.nix`, in the `let` block of your `eachDefaultSystem` output, add the following:
    ```nix
    let
      # ... existing let bindings
      secretsConfig = import ./secrets.nix { inherit pkgs lib; };

      # Derivation to decrypt sops secrets
      decryptedSopsSecrets = pkgs.stdenv.mkDerivation {
        pname = "decrypted-sops-secrets";
        version = "1.0";
        
        buildPhase = ''
          mkdir -p $out/.gemini
          ${pkgs.sops}/bin/sops -d ./sops-secrets/oauth_creds.json > $out/.gemini/oauth_creds.json
          ${pkgs.sops}/bin/sops -d ./sops-secrets/settings.json > $out/.gemini/settings.json
          ${pkgs.sops}/bin/sops -d ./sops-secrets/google_accounts.json > $out/.gemini/google_accounts.json
        '';
        
        buildInputs = [ pkgs.sops ];
      };
      # ... rest of your let bindings
    in
    # ... your outputs
    ```

2.  **Use `decryptedSopsSecrets` in your main derivation:**
    In the `buildInputs` of your main derivation (e.g., `buildTimeTelemetry`, `impureGeminiTelemetry`, `gemini-prompt-output`), add `decryptedSopsSecrets`. Then, in the `buildPhase`, copy the decrypted files from `${decryptedSopsSecrets}/.gemini/` to the temporary `$HOME/.gemini/` directory.

    Example `buildPhase` snippet:
    ```bash
    buildPhase = ''
      # ... existing buildPhase content
      export HOME=$(mktemp -d)
      trap 'rm -rf "$HOME"' EXIT
      mkdir -p $HOME/.gemini/
      cp ${decryptedSopsSecrets}/.gemini/settings.json $HOME/.gemini/
      cp ${decryptedSopsSecrets}/.gemini/oauth_creds.json $HOME/.gemini/
      cp ${decryptedSopsSecrets}/.gemini/google_accounts.json $HOME/.gemini/
      echo "✅ Credentials copied from decryptedSopsSecrets to $HOME/.gemini/"
      # ... rest of your buildPhase content
    '';
    ```

2.  **Use `decryptedSopsSecrets` in your main derivation:**
    In the `buildInputs` of your main derivation (e.g., `buildTimeTelemetry`, `impureGeminiTelemetry`, `gemini-prompt-output`), add `decryptedSopsSecrets`. Then, in the `buildPhase`, copy the decrypted files from `${decryptedSopsSecrets}/.gemini/` to the temporary `$HOME/.gemini/` directory.

    Example `buildPhase` snippet:
    ```bash
    buildPhase = ''
      # ... existing buildPhase content
      export HOME=$(mktemp -d)
      trap 'rm -rf "$HOME"' EXIT
      mkdir -p $HOME/.gemini/
      cp ${decryptedSopsSecrets}/.gemini/settings.json $HOME/.gemini/
      cp ${decryptedSopsSecrets}/.gemini/oauth_creds.json $HOME/.gemini/
      cp ${decryptedSopsSecrets}/.gemini/google_accounts.json $HOME/.gemini/
      echo "✅ Credentials copied from decryptedSopsSecrets to $HOME/.gemini/"
      # ... rest of your buildPhase content
    '';
    ```

### 4.4. Integrating with Makefiles

Makefiles can be used to streamline various tasks related to `sops-nix` and secret management, especially during development and testing.

#### 4.4.1. Encrypting/Decrypting Secrets

You can define Makefile targets to simplify the encryption and decryption of secrets. This is particularly useful when you need to modify a secret and re-encrypt it.

```makefile
.PHONY: encrypt-secrets decrypt-secrets

encrypt-secrets:
	@echo "Encrypting sops secrets..."
	sops --encrypt --in-place sops-secrets/oauth_creds.json
	sops --encrypt --in-place sops-secrets/settings.json
	sops --encrypt --in-place sops-secrets/google_accounts.json
	@echo "Sops secrets encrypted."

decrypt-secrets:
	@echo "Decrypting sops secrets for local development (DO NOT COMMIT DECRYPTED FILES!)..."
	sops --decrypt --in-place sops-secrets/oauth_creds.json
	sops --decrypt --in-place sops-secrets/settings.json
	sops --decrypt --in-place sops-secrets/google_accounts.json
	@echo "Sops secrets decrypted."
```

#### 4.4.2. Running Nix Builds with Secrets

Makefiles can also be used to trigger Nix builds that depend on `sops-nix` managed secrets. This ensures that the build process correctly picks up the decrypted secrets.

```makefile
.PHONY: build-project-with-secrets

build-project-with-secrets:
	@echo "Building project with sops-nix managed secrets..."
	nix build .#your-derivation-name --show-trace
	@echo "Project build complete."
```

#### 4.4.3. Setting up Development Environments

For local development, you might want to set up a `devShell` that provides access to decrypted secrets. Makefiles can help in activating such environments.

```makefile
.PHONY: devshell-with-secrets

devshell-with-secrets:
	@echo "Entering development shell with sops-nix secrets..."
	nix develop .#your-devshell-name
```

## 5. Verification

*   **Build the flake:** Run `nix build .#your-derivation` to ensure the build completes successfully.
*   **Check logs:** Review the build logs to confirm that the "Credentials copied from decryptedSopsSecrets" message appears and that `gemini-cli` (or other tools) can access the credentials.
*   **Security audit:** Periodically audit the repository to ensure no sensitive information is committed in plain text.

## 6. References

*   CRQ-019: Secure Credential Handling in Nix Scripts
*   `sops-nix` documentation: [Link to sops-nix GitHub/docs] (Replace with actual link)