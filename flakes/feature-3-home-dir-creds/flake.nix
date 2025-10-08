{
  description = "Feature 3: Home Directory Credentials - Makes ~/.gemini credentials available.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    gemini-cli.url = "github:meta-introspector/gemini-cli?ref=feature/CRQ-016-nixify-2025-10-06";

    # Reference the credential-setup.nix module
    credentialSetup = {
      url = "path:../../flakes/gemini-feature-lattice/credential-setup.nix";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, gemini-cli, credentialSetup, hostGeminiHome ? "/data/data/com.termux.nix/files/home/.gemini", ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit lib;

        # The path to the user's actual ~/.gemini directory on the host
        # This makes the flake impure, but necessary for this feature
        # hostGeminiHome is now configurable via flake inputs or defaults to the hardcoded path

        # Use the credentialSetup module to create a derivation that sets up credentials
        geminiCredsDerivation = credentialSetup {
          inherit lib pkgs;
          geminiCliPackage = gemini-cli.packages.${system}.default;
          credentialsPath = hostGeminiHome; # Pass the host's ~/.gemini path
        };

        # A wrapper script to run gemini-cli with the setup credentials
        geminiCliWithHomeCreds = pkgs.writeShellScriptBin "gemini-cli-with-home-creds" ''
          # The geminiCredsDerivation outputs a path to a temporary HOME
          # We need to read that path from the derivation's output
          TEMP_HOME_PATH=$(cat ${geminiCredsDerivation}/home_path)
          export HOME="$TEMP_HOME_PATH"

          exec ${gemini-cli.packages.${system}.default}/bin/gemini-cli "$@"
        '';

      in
      {
        packages = {
          inherit geminiCliWithHomeCreds;
        };

        apps = {
          default = flake-utils.lib.mkApp {
            drv = geminiCliWithHomeCreds;
          };
        };

        devShells.default = pkgs.mkShell {
          buildInputs = [
            gemini-cli.packages.${system}.default
            geminiCliWithHomeCreds
          ];

          shellHook = ''
            echo "Welcome to the gemini-cli devShell with home directory credentials enabled."
            echo "Use 'gemini-cli-with-home-creds' to run gemini-cli with credentials from your host ~/.gemini."
          '';
        };
      }
    );
}