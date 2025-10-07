{
  description = "A flake to test sops-nix integration with gemini-cli";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    sops-nix.url = "github:meta-introspector/sops-nix?ref=feature/working-gemini-cli-nix-store";
    gemini-cli.url = "github:meta-introspector/gemini-cli?ref=feature/working-gemini-cli-nix-store";

    # Reference the secrets.nix from the parent directory
    secrets = {
      url = "path:../";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, sops-nix, gemini-cli, secrets, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit lib;

        # Import the secrets.nix from the parent directory
        secretsConfig = import secrets { inherit pkgs lib; };

        # Derivation to decrypt sops secrets
        decryptedSopsSecrets = pkgs.stdenv.mkDerivation {
          pname = "decrypted-gemini-sops-secrets";
          version = "1.0";

          buildPhase = ''
            mkdir -p $out/.gemini
            ${pkgs.sops}/bin/sops -d ../sops-secrets/oauth_creds.json > $out/.gemini/oauth_creds.json
            ${pkgs.sops}/bin/sops -d ../sops-secrets/settings.json > $out/.gemini/settings.json
            ${pkgs.sops}/bin/sops -d ../sops-secrets/google_accounts.json > $out/.gemini/google_accounts.json
          '';

          buildInputs = [ pkgs.sops ];
        };

        # A wrapper script to run gemini-cli with decrypted secrets
        geminiCliWithSecrets = pkgs.writeShellScriptBin "gemini-cli-with-secrets" ''
          export HOME=$(mktemp -d)
          trap 'rm -rf "$HOME"' EXIT
          mkdir -p "$HOME/.gemini/"
          cp ${decryptedSopsSecrets}/.gemini/settings.json "$HOME/.gemini/"
          cp ${decryptedSopsSecrets}/.gemini/oauth_creds.json "$HOME/.gemini/"
          cp ${decryptedSopsSecrets}/.gemini/google_accounts.json "$HOME/.gemini/"
          echo "✅ Credentials copied from decryptedSopsSecrets to $HOME/.gemini/"
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