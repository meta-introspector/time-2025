{
  description = "Consolidated Nix flake for Gemini CLI and API integration, providing various interaction methods.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    gemini-cli.url = "github:meta-introspector/gemini-cli?ref=feature/working-gemini-cli-nix-store";
    # Input for the Python API consumer
    gemini-api-consumer-flake.url = "path:./gemini_api_consumer_flake";
  };

  outputs = { self, nixpkgs, flake-utils, gemini-cli, gemini-api-consumer-flake }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # --- From gemini_runner_flake ---
        geminiCliSrc = gemini-cli; # This refers to the entire flake's source
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
        geminiCliRunnerApp = pkgs.writeShellScript "gemini-cli-runner-app" ''
          echo "--- Running gemini-cli from derivation with internal logs ---"

          # Ensure Node.js is in PATH
          export PATH=${pkgs.nodejs}/bin:$PATH

          # Set GEMINI_CONFIG_PATH to point to the generated settings.json
          export GEMINI_CONFIG_PATH=${geminiCliPackage}/etc/gemini-cli/settings.json

          # Execute gemini.js from the built package
          exec ${geminiCliPackage}/bin/gemini.js "$@"
        '';

        # --- From gemini_api_consumer_flake ---
        geminiConsumerApp = gemini-api-consumer-flake.apps.${system}.default;

      in
      {
        # Consolidated Development Shell
        devShells.default = pkgs.mkShell {
          # Inherit buildInputs from gemini-cli's devShell (from my_gemini_flake)
          inherit (gemini-cli.devShells.${system}.default) buildInputs;

          # Add bash for general shell scripting (from gemini_with_home_access_flake)
          buildInputs = (gemini-cli.devShells.${system}.default.buildInputs or []) ++ [ pkgs.bash geminiConsumerApp ];

          shellHook = ''
            echo "Welcome to the consolidated Gemini Integration devShell!"
            echo "The gemini-cli environment is available."
            echo "The 'gemini-api-consumer-app' is available."

            # Create a symlink to the user's actual ~/.gemini directory (from gemini_with_home_access_flake)
            export GEMINI_HOME_DIR="$HOME/.gemini"
            mkdir -p "$GEMINI_HOME_DIR" # Ensure the actual directory exists

            export XDG_CONFIG_HOME=$(mktemp -d)
            ln -s "$GEMINI_HOME_DIR" "$XDG_CONFIG_HOME/.gemini"

            echo "Symlink created: $XDG_CONFIG_HOME/.gemini -> $GEMINI_HOME_DIR"
            echo "You can now access your Gemini configuration via ~/.gemini within this shell."
            echo "Remember to set GEMINI_API_KEY if you haven't already: export GEMINI_API_KEY='YOUR_API_KEY'"
          '';
        };

        # App for running gemini-cli from a derivation
        apps.geminiCliRunner = {
          type = "app";
          program = geminiCliRunnerApp;
        };

        # App for Python API consumption
        apps.geminiApiConsumer = {
          type = "app";
          program = geminiConsumerApp;
        };

        # Default package (can be the gemini-cli-runner for simplicity)
        packages.default = geminiCliPackage;
      }
    );
}