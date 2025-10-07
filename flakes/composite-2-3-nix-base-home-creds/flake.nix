{
  description = "Composite Flake: Combines Nix Base (2) and Home Directory Credentials (3).";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    gemini-cli.url = "github:meta-introspector/gemini-cli?ref=feature/CRQ-016-nixify-2025-10-06";

    # Feature flakes as inputs
    feature2 = {
      url = "path:../feature-2-nix-base";
      flake = false; # Not a flake itself, just a path to its lib
    };
    feature3 = {
      url = "path:../feature-3-home-dir-creds";
      flake = false; # Not a flake itself, just a path to its lib
    };
  };

  outputs = { self, nixpkgs, flake-utils, gemini-cli, feature2, feature3, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        # Get pkgs and lib from feature-2-nix-base
        baseLib = import feature2 { inherit nixpkgs flake-utils; }.lib.${system};
        inherit (baseLib) pkgs lib;

        # Get the geminiCliWithHomeCreds from feature-3-home-dir-creds
        homeCredsApp = import feature3 { inherit nixpkgs flake-utils gemini-cli; }.apps.${system}.default;

      in
      {
        packages = {
          inherit (homeCredsApp) default; # Expose the app from feature-3
        };

        apps = {
          default = homeCredsApp;
        };

        devShells.default = pkgs.mkShell {
          buildInputs = [
            gemini-cli.packages.${system}.default
            homeCredsApp.drv # Access the underlying derivation of the app
          ];

          shellHook = ''
            echo "Welcome to the composite devShell with Nix Base and Home Directory Credentials."
            echo "Use 'gemini-cli-with-home-creds' to run gemini-cli with credentials from your host ~/.gemini."
          '';
        };
      }
    );
}