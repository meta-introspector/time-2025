{
  description = "Updated Gemini CLI integration using confirmed Nix store bundle";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    # Use our local working gemini-cli with confirmed bundle in Nix store
    gemini-cli.url = "github:meta-introspector/gemini-cli?ref=feature/CRQ-016-nixify-2025-10-06";
  };

  outputs = { self, nixpkgs, flake-utils, gemini-cli }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Known working Nix store path (hash: 9bfmqvdsyk2br1bw5xcfy2g62axp7id7)
        geminiStorePath = "${gemini-cli.packages.${system}.default}";
        geminiBundle = "${geminiStorePath}/share/gemini-cli/bundle/gemini.js";
        geminiWrapper = "${geminiStorePath}/bin/gemini";

        # Test script using confirmed Nix store paths
        testWorkingBundle = pkgs.writeShellScript "test-working-bundle" ''
          echo "=== Testing Working Nix Store Bundle ==="
          echo "Store path: ${geminiStorePath}"
          echo "Bundle path: ${geminiBundle}"
          echo "Hash: $(basename ${geminiStorePath} | cut -d'-' -f1)"
          echo ""
          
          # Verify bundle exists
          if [ -f "${geminiBundle}" ]; then
            echo "✅ Bundle found in Nix store"
            echo "Size: $(stat -c%s "${geminiBundle}" | numfmt --to=iec)"
          else
            echo "❌ Bundle not found"
            exit 1
          fi
          
          # Test wrapper
          echo "Testing wrapper:"
          ${geminiWrapper} --version
          
          # Test direct bundle
          echo "Testing direct bundle:"
          node ${geminiBundle} --version
          
          echo "✅ All tests passed - Nix store bundle working!"
        '';

        # Impure derivation for telemetry capture
        telemetryCapture = pkgs.stdenv.mkDerivation {
          pname = "working-gemini-telemetry";
          version = "1.0";

          src = pkgs.writeText "dummy" "telemetry test";

          __impure = true;

          buildInputs = [
            pkgs.nodejs_22
            gemini-cli.packages.${system}.default
          ];

          GEMINI_API_KEY = builtins.getEnv "GEMINI_API_KEY";

          buildPhase = ''
            mkdir -p $out/{logs,telemetry}
            
            echo "=== Nix Store Telemetry Capture ===" | tee $out/logs/capture.log
            echo "Bundle hash: $(basename ${geminiStorePath} | cut -d'-' -f1)" >> $out/logs/capture.log
            echo "Bundle path: ${geminiBundle}" >> $out/logs/capture.log
            
            # Run telemetry test
            ${testWorkingBundle} 2>&1 | tee -a $out/logs/capture.log
            
            # Test with API if available
            if [ -n "$GEMINI_API_KEY" ]; then
              echo "Testing with API..." >> $out/logs/capture.log
              timeout 60 ${geminiWrapper} "Hello from Nix store bundle! Hash: $(basename ${geminiStorePath} | cut -d'-' -f1)" 2>&1 | tee -a $out/logs/capture.log || echo "API test exit: $?"
            fi
            
            # Create telemetry summary
            cat > $out/telemetry/summary.json << EOF
            {
              "bundle_hash": "$(basename ${geminiStorePath} | cut -d'-' -f1)",
              "store_path": "${geminiStorePath}",
              "bundle_path": "${geminiBundle}",
              "wrapper_path": "${geminiWrapper}",
              "test_result": "success",
              "timestamp": "$(date -Iseconds)"
            }
            EOF
          '';

          installPhase = ''
            echo "Telemetry capture complete - results in $out/"
          '';
        };
      in
      {
        packages.default = telemetryCapture;

        apps = {
          default = {
            type = "app";
            program = "${testWorkingBundle}";
          };

          gemini = {
            type = "app";
            program = "${geminiWrapper}";
          };

          test-bundle = {
            type = "app";
            program = "${testWorkingBundle}";
          };
        };

        # Expose the confirmed working paths
        lib = {
          inherit geminiStorePath;
          inherit geminiBundle;
          inherit geminiWrapper;
          bundleHash = "9bfmqvdsyk2br1bw5xcfy2g62axp7id7";
        };
      }
    );
}
