{
  description = "A flake to test sops-nix integration with gemini-cli";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    sops-nix.url = "github:meta-introspector/sops-nix?ref=feature/working-gemini-cli-nix-store";
    gemini-cli.url = "github:meta-introspector/gemini-cli?ref=feature/CRQ-016-nixify-2025-10-06";

    # Reference the secrets.nix from the parent directory
    secrets = {
      url = "path:../";
      flake = false;
    };

    sops-secrets-dir = {
      url = "path:../../sops-secrets"; # Path relative to the wrap-gemini-secrets flake
      flake = false;
    };
  }; # Closing brace for inputs

  outputs = { self, nixpkgs, flake-utils, sops-nix, gemini-cli, secrets, sops-secrets-dir, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        inherit lib;
        pkgs = nixpkgs.legacyPackages.${system};

        # Import the secrets.nix from the parent directory
        secretsConfig = import secrets { inherit pkgs lib; };

        # This derivation is no longer needed as decryption happens outside
        # decryptedSopsSecrets = ...

        # A wrapper script to run gemini-cli with decrypted secrets
        # It now expects the path to the decrypted secrets as an argument
        geminiCliWithSecrets = pkgs.writeShellScriptBin "gemini-cli-with-secrets" ''
          # The first argument to this script will be the path to the decrypted secrets
          DECRYPTED_SECRETS_PATH="$1"
          shift # Remove the first argument, so "$@" now contains gemini-cli arguments

          export HOME=$(mktemp -d)
          trap 'rm -rf "$HOME"' EXIT
          mkdir -p "$HOME/.gemini/"
          cp -r "$DECRYPTED_SECRETS_PATH"/* "$HOME/.gemini/"
          echo "✅ Credentials copied from $DECRYPTED_SECRETS_PATH to $HOME/.gemini/"
          exec ${gemini-cli.packages.${system}.default}/bin/gemini-cli "$@"
        '';

      in
      {
        packages = {
          inherit geminiCliWithSecrets;
        };

        apps = {
          default = flake-utils.lib.mkApp {
            drv = geminiCliWithSecrets;
          };
        };

        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.sops
            gemini-cli.packages.${system}.default
            geminiCliWithSecrets
          ];

          shellHook = ''
            echo "Welcome to the gemini-cli devShell with sops secrets enabled."
            echo "Use 'gemini-cli-with-secrets' to run gemini-cli with decrypted credentials."
          '';
        };
      }
    );
}