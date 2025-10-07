{
  description = "Consolidated Impure Gemini CLI telemetry capture and credential testing.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    sops-nix.url = "github:meta-introspector/sops-nix?ref=feature/working-gemini-cli-nix-store";
    gemini-cli.url = "github:meta-introspector/gemini-cli?ref=feature/CRQ-016-nixify-2025-10-06";
  };

  outputs = { self, nixpkgs, flake-utils, gemini-cli }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Import the secrets definition
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

        # Test script for impure telemetry capture and credential handling
        impureTelemetryScript = pkgs.writeShellScript "impure-telemetry" ''
          #!/usr/bin/env bash
          set -e
          
          echo "=== Impure Gemini Telemetry Capture Started ==="
          echo "Timestamp: $(date -Iseconds)"
          echo "GitHub Branch: feature/working-gemini-cli-nix-store" 
          echo "Gemini CLI from GitHub: ${gemini-cli.packages.${system}.default}/bin/gemini"
          echo ""
          
          # Credential handling using decrypted sops secrets
          GEMINI_CONFIG_DIR="/tmp/.gemini" # Use a known writable temporary directory
          mkdir -p "$GEMINI_CONFIG_DIR" # Create the .gemini directory
          
          cp ${decryptedSopsSecrets}/.gemini/oauth_creds.json "$GEMINI_CONFIG_DIR/"
          echo "Copied oauth_creds.json to $GEMINI_CONFIG_DIR/"

          cp ${decryptedSopsSecrets}/.gemini/google_accounts.json "$GEMINI_CONFIG_DIR/"
          echo "Copied google_accounts.json to $GEMINI_CONFIG_DIR/"

          cp ${decryptedSopsSecrets}/.gemini/settings.json "$GEMINI_CONFIG_DIR/"
          echo "Copied settings.json to $GEMINI_CONFIG_DIR/"
          
          export GEMINI_CONFIG_PATH="$GEMINI_CONFIG_DIR/settings.json"
          echo "✅ Credentials copied from decryptedSopsSecrets to $GEMINI_CONFIG_DIR/"
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
          timeout 60 ${gemini-cli.packages.${system}.default}/bin/gemini "Hello from GitHub impure derivation! Capturing telemetry for Nix store gemini.js integration." || echo "Prompt exit: $?"
          
          echo ""
          echo "=== Telemetry Capture Complete ==="
        '';

        # Impure derivation for telemetry capture
        impureGeminiTelemetry = pkgs.stdenv.mkDerivation {
          pname = "consolidated-impure-gemini-telemetry";
          version = "1.0";

          src = pkgs.writeText "dummy" "consolidated impure test";

          __impure = true;

          buildInputs = [
            pkgs.nodejs_22
            pkgs.jq
            pkgs.curl
            gemini-cli.packages.${system}.default
            decryptedSopsSecrets # Add the derivation that decrypts sops secrets
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
        packages.default = impureGeminiTelemetry;

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