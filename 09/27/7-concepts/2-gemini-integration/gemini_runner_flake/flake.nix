{
  description = "A Nix flake to run gemini-cli from within a derivation.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    gemini-cli.url = "github:meta-introspector/gemini-cli?ref=feature/working-gemini-cli-nix-store";
  };

  outputs = { self, nixpkgs, flake-utils, gemini-cli }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        geminiCliDevShell = gemini-cli.devShells.${system}.default;

        # We need to find the actual gemini.js path.
        # Assuming gemini-cli's devShell makes it available or we can find it in its source.
        # For now, let's assume it's part of the gemini-cli's default package if it had one,
        # or we can extract it from its source.
        # Since my_gemini_flake says "not a direct runnable app or package",
        # we might need to build it ourselves from the gemini-cli source.

        # Let's try to get the source of gemini-cli and then find gemini.js
        geminiCliSrc = gemini-cli; # This refers to the entire flake's source

        # A derivation to build gemini-cli if it's a Node.js project
        # This is a speculative step, as I don't have the exact structure of gemini-cli
        # If gemini-cli is a simple JS file, we might just need node and the file.
        geminiCliPackage = pkgs.stdenv.mkDerivation {
          pname = "gemini-cli-runner";
          version = "0.1.0";
          src = geminiCliSrc;

          buildInputs = [ pkgs.nodejs ];

          installPhase = ''
            mkdir -p $out/bin
            cp $src/bundle/gemini.js $out/bin/gemini.js
            chmod +x $out/bin/gemini.js

            # Create settings.json within the derivation
            mkdir -p $out/etc/gemini-cli
            echo '{
              "logsDir": "$out/logs"
            }' > $out/etc/gemini-cli/settings.json

            # Create the logs directory within the derivation
            mkdir -p $out/logs
          '';
        };

        # Wrapper script to set up ~/.gemini access and run gemini-cli
        geminiCliWrapper = pkgs.writeShellScript "gemini-cli-wrapper" ''
          echo "--- Running gemini-cli from derivation with internal logs ---"

          # Ensure Node.js is in PATH
          export PATH=${pkgs.nodejs}/bin:$PATH

          # Set GEMINI_CONFIG_PATH to point to the generated settings.json
          export GEMINI_CONFIG_PATH=${geminiCliPackage}/etc/gemini-cli/settings.json

          # Execute gemini.js from the built package
          exec ${geminiCliPackage}/bin/gemini.js "$@"
        '';

      in
      {
        apps.default = {
          type = "app";
          program = geminiCliWrapper;
        };

        packages.default = geminiCliPackage;
      }
    );
}
