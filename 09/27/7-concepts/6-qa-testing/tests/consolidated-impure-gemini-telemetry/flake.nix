{
  description = "Consolidated Impure Gemini CLI telemetry capture and credential testing.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    gemini-cli.url = "github:meta-introspector/gemini-cli?ref=feature/CRQ-016-nixify-2025-10-06";
    vial.url = "path:./vial-placeholder"; # Placeholder for the actual vial flake
    mycologyContext = { }; # Optional input for mycology framework context
    credsSourceDir.url = "path:./default-creds-source"; # Default placeholder for the creds source directory
  };

  outputs = { self, nixpkgs, flake-utils, gemini-cli, credsSourceDir ? "/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/time-2025/09/27/7-concepts/creds" } @ inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        # sopsSecretsPath = lib.attrByPath [ "sopsSecretsPath" ] null mycologyContext;



        # Test script for impure telemetry capture and credential handling
        impureTelemetryScript = pkgs.writeShellScript "impure-telemetry" ''
          #!/usr/bin/env bash
          set -e
          
          echo "=== Impure Gemini Telemetry Capture Started ==="
          echo "Timestamp: $(date -Iseconds)"
          echo "GitHub Branch: feature/working-gemini-cli-nix-store" 
          echo "Gemini CLI from GitHub: ${gemini-cli.packages.${system}.default}/bin/gemini"
          echo ""
          
          # Credential handling from gemini-telemetry-capture-v3
          mkdir -p creds
          # CRITICAL: This assumes the 'creds' directory is available in the source of this flake.
          # In a real scenario, this would need to be handled more robustly, e.g., via sops-nix or explicit passing.
          # For this test, we'll simulate its presence or assume it's copied by the build system.
          # For now, we'll just check for its existence and warn if not found.
          if [ -d "${credsSourceDir}" ]; then
            cp -r ${credsSourceDir}/* creds/
            echo "Attempting to copy credential files from creds/"
            ls -la creds/ # Check if creds directory exists and its contents
            GEMINI_CONFIG_DIR="/tmp/.gemini" # Use a known writable temporary directory
            mkdir -p "$GEMINI_CONFIG_DIR" # Create the .gemini directory
            # Copy specific credential files from creds/
            if [ -f "creds/oauth_creds.json" ]; then
              cp "creds/oauth_creds.json" "$GEMINI_CONFIG_DIR/"
              echo "Copied oauth_creds.json to $GEMINI_CONFIG_DIR/"
            else
              echo "Warning: creds/oauth_creds.json not found."
            fi

            if [ -f "creds/google_accounts.json" ]; then
              cp "creds/google_accounts.json" "$GEMINI_CONFIG_DIR/"
              echo "Copied google_accounts.json to $GEMINI_CONFIG_DIR/"
            else
              echo "Warning: creds/google_accounts.json not found."
            fi

            if [ -f "creds/settings.json" ]; then
              cp "creds/settings.json" "$GEMINI_CONFIG_DIR/"
              echo "Copied settings.json to $GEMINI_CONFIG_DIR/"
            else
              echo "Warning: creds/settings.json not found."
            fi
            export GEMINI_CONFIG_PATH="$GEMINI_CONFIG_DIR/settings.json"
          else
            echo "Warning: 'creds' directory not found in source. Credential copying skipped."
          fi
          echo ""
          
          # Check API key
          if [ -n "$GEMINI_API_KEY" ]; then
            echo "GEMINI_API_KEY: SET (''${#GEMINI_API_KEY} chars)"
          else
            echo "GEMINI_API_KEY: NOT SET"
          fi
          
          # Test the GitHub gemini CLI package
          echo "=== Testing GitHub Gemini CLI Package ==="
          echo "Version test:"
          timeout 30 ${gemini-cli.packages.${system}.default}/bin/gemini --version || echo "Version exit: $?"
          
          echo ""
          echo "Help test:" 
          timeout 30 ${gemini-cli.packages.${system}.default}/bin/gemini --help | head -20 || echo "Help exit: $?"
          
          echo ""
          echo "Telemetry prompt test:"
          timeout 60 ${gemini-cli.packages.${system}.default}/bin/gemini "${geminiPrompt}" || echo "Prompt exit: $?"
          
          echo ""
          echo "=== Telemetry Capture Complete ==="
        '';

        # Impure derivation for telemetry capture
        impureGeminiTelemetry = {  mycologyContext }: pkgs.stdenv.mkDerivation {
          pname = "consolidated-impure-gemini-telemetry";
          version = "1.0";

          src = pkgs.writeText "dummy" "consolidated impure test";
          dontUnpack = true;

          __impure = true;

          buildInputs = [
            pkgs.nodejs_22
            pkgs.jq
            pkgs.curl
            gemini-cli.packages.${system}.default
          ];

          GEMINI_API_KEY = builtins.getEnv "GEMINI_API_KEY";

          buildPhase = ''
            echo "=== Consolidated Impure Build Phase ==="
            mkdir -p $out/{logs,telemetry}
            
            # Run telemetry capture script
            ${impureTelemetryScript} 2>&1 | tee $out/logs/impure-telemetry.log

            # Create telemetry summary (from github-gemini-impure)
            cat > $out/telemetry/summary.json << EOF
            {
              "timestamp": "$(date -Iseconds)",
              "test_type": "consolidated_impure_derivation",
              "gemini_cli_source": "github:meta-introspector/gemini-cli?ref=feature/working-gemini-cli-nix-store",
              "nix_store_bundle": "available",
              "status": "completed"
            }
            EOF
            
            echo "✓ Consolidated impure telemetry capture complete"
          '';

          installPhase = ''
            echo "=== Consolidated Impure Telemetry Installation ==="
            echo "Installation complete - logs in $out/logs/impure-telemetry.log"
            echo "JSON summary in $out/telemetry/summary.json"
          '';
        };
      in
      {
        lib.runTelemetry = { mycologyContext }: impureGeminiTelemetry { inherit mycologyContext; };

        packages.default = impureGeminiTelemetry {

          mycologyContext = { }; # Provide a default context
        };

        apps.default = {
          type = "app";
          program = impureTelemetryScript;
        };

        apps.gemini = {
          type = "app";
          program = "${gemini-cli.packages.${system}.default}/bin/gemini";
        };
      }
    );
}