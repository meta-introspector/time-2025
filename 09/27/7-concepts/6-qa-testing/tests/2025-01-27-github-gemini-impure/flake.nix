{
  description = "Impure Gemini CLI telemetry capture using GitHub URL with working Nix package";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    # Use our working gemini-cli directly from GitHub
    gemini-cli.url = "github:meta-introspector/gemini-cli?ref=feature/working-gemini-cli-nix-store";
  };

  outputs = { self, nixpkgs, flake-utils, gemini-cli }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Test script for impure telemetry capture
        impureTelemetryScript = pkgs.writeShellScript "impure-telemetry" ''
          #!/usr/bin/env bash
          set -e
          
          echo "=== Impure Gemini Telemetry Capture Started ==="
          echo "Timestamp: $(date -Iseconds)"
          echo "GitHub Branch: feature/working-gemini-cli-nix-store" 
          echo "Gemini CLI from GitHub: ${gemini-cli.packages.${system}.default}/bin/gemini"
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
          pname = "impure-github-gemini-telemetry";
          version = "1.0";

          src = pkgs.writeText "dummy" "github impure test";

          __impure = true;

          buildInputs = [
            pkgs.nodejs_22
            pkgs.strace
            gemini-cli.packages.${system}.default
          ];

          GEMINI_API_KEY = builtins.getEnv "GEMINI_API_KEY";

          buildPhase = ''
            echo "=== Impure Build Phase ==="
            mkdir -p $out/{logs,telemetry}
            
            # Run telemetry capture
            ${impureTelemetryScript} 2>&1 | tee $out/logs/github-impure-telemetry.log
          '';

          installPhase = ''
            echo "=== GitHub Impure Telemetry Installation ==="
            
            # Create telemetry summary
            cat > $out/telemetry/github-summary.json << EOF
            {
              "timestamp": "$(date -Iseconds)",
              "test_type": "github_impure_derivation",
              "gemini_cli_source": "github:meta-introspector/gemini-cli?ref=feature/test",
              "nix_store_bundle": "available",
              "status": "completed"
            }
            EOF
            
            echo "✓ GitHub impure telemetry capture complete"
          '';
        };
      in
      {
        packages.default = impureGeminiTelemetry;

        apps.default = {
          type = "app";
          program = "${impureTelemetryScript}";
        };

        apps.gemini = {
          type = "app";
          program = "${gemini-cli.packages.${system}.default}/bin/gemini";
        };
      }
    );
}
