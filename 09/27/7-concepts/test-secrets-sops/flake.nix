{
  description = "A minimal test flake for build-time sops-nix secrets";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    sops-nix.url = "github:meta-introspector/sops-nix?ref=feature/working-gemini-cli-nix-store";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
  };

  outputs = { self, nixpkgs, sops-nix, flake-utils, ... }: {
    inherit (flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

      in
      {
        packages = {
          secret-consumer = pkgs.stdenv.mkDerivation {
            pname = "secret-consumer";
            version = "1.0";
            src = self; # Use the flake itself as the source

            # This build will now be impure, relying on an environment variable.
            # CRITICAL: This is INSECURE for sensitive secrets.
            buildPhase = pkgs.writeShellScript "build-phase-script" ''
              BUILD_SECRET_HELLO="${builtins.getEnv "BUILD_SECRET_HELLO" ""}"
              echo "Attempting to access secret 'hello' during impure build..."

              if [ -n "$BUILD_SECRET_HELLO" ]; then
                echo "Secret 'hello' was successfully accessed during impure build." > status.tmp
                # For demonstration, we'll write a success message.
                # In a real scenario, you would use $BUILD_SECRET_HELLO here.
                # BUT BE CAREFUL: This would write the secret to the Nix store!
              else
                echo "Error: Secret 'hello' (BUILD_SECRET_HELLO) was NOT provided for impure build." > status.tmp
                exit 1
              fi
            '';
            installPhase = ''
              mkdir -p $out/bin
              mv status.tmp $out/status.txt
              cp $out/status.txt $out/bin/
            '';
          };
        };

        # The devShell is no longer configured for sops-nix in this example
        devShells = {
          default = pkgs.mkShell {
            packages = [ self.packages.${system}.secret-consumer ];
            shellHook = ''
              echo "Welcome to the devShell. To test the impure build, run:"
              echo "BUILD_SECRET_HELLO=\"my-impure-secret\" nix build .#secret-consumer"
            '';
          };
        };
      })) packages devShells;
  };
}
