{
  description = "Build-time Gemini telemetry capture - calls Gemini during Nix build";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    # Use our local working gemini-cli with confirmed bundle in Nix store
    gemini-cli.url = "github:meta-introspector/gemini-cli?ref=feature/working-gemini-cli-nix-store";
  };

  outputs = { self, nixpkgs, flake-utils, gemini-cli }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Build-time telemetry capture derivation
        buildTimeTelemetry = pkgs.stdenv.mkDerivation {
          pname = "build-time-gemini-telemetry";
          version = "1.0";

          src = pkgs.writeText "dummy" "build telemetry";

          __impure = true;

          buildInputs = [
            pkgs.nodejs_22
            pkgs.jq
            pkgs.curl
            gemini-cli.packages.${system}.default
          ];

          # Environment variables for build
          GEMINI_API_KEY = builtins.getEnv "GEMINI_API_KEY";
          NIX_BUILD_TELEMETRY = "true";

          buildPhase = ''
            echo "🔥 BUILD-TIME GEMINI TELEMETRY CAPTURE 🔥"
            
            mkdir -p $out/{logs,telemetry,analysis}
            
            # Capture build environment
            {
              echo "=== Nix Build Environment ==="
              echo "Timestamp: $(date -Iseconds)"
              echo "Build in progress: YES"
              echo "Derivation: build-time-gemini-telemetry"
              echo "PWD: $(pwd)"
              echo ""
              
              # Bundle verification 
              echo "=== Bundle Verification ==="
              BUNDLE_PATH="${gemini-cli.packages.${system}.default}/share/gemini-cli/bundle/gemini.js"
              WRAPPER_PATH="${gemini-cli.packages.${system}.default}/bin/gemini"
              BUNDLE_HASH="$(basename ${gemini-cli.packages.${system}.default} | cut -d'-' -f1)"
              
              echo "Bundle hash: $BUNDLE_HASH"
              echo "Bundle path: $BUNDLE_PATH"
              echo "Wrapper path: $WRAPPER_PATH"
              
              if [ -f "$BUNDLE_PATH" ]; then
                BUNDLE_SIZE=$(stat -c%s "$BUNDLE_PATH")
                echo "✅ Bundle found: $(numfmt --to=iec $BUNDLE_SIZE)"
              else
                echo "❌ Bundle not found!"
                exit 1
              fi
              echo ""
              
              # API key check
              if [ -n "$GEMINI_API_KEY" ]; then
                echo "🔑 API Key: SET (''${#GEMINI_API_KEY} chars)"
                WILL_CALL_API="true"
              else
                echo "🔑 API Key: NOT SET (test mode)"
                WILL_CALL_API="false"
              fi
              echo ""
              
              # ACTUAL GEMINI CALLS DURING BUILD
              echo "🚀 CALLING GEMINI DURING NIX BUILD 🚀"
              
              echo "1. Version check:"
              if timeout 30 "$WRAPPER_PATH" --version; then
                echo "✅ Version call successful"
              else
                echo "❌ Version call failed (exit: $?)"
              fi
              
              echo ""
              echo "2. Help check:"
              if timeout 30 "$WRAPPER_PATH" --help | head -5; then
                echo "✅ Help call successful"
              else
                echo "❌ Help call failed (exit: $?)"
              fi
              
              echo ""
              echo "3. BUILD-TIME API CALL:"
              if [ "$WILL_CALL_API" = "true" ]; then
                echo "🌟 Making actual API call during build..."
                if timeout 120 "$WRAPPER_PATH" "I am calling you from INSIDE a Nix build derivation! This is real-time telemetry capture. Bundle hash: $BUNDLE_HASH. Time: $(date)"; then
                  echo "✅ BUILD-TIME API CALL SUCCESSFUL!"
                else
                  echo "⚠️ API call completed with exit code: $?"
                fi
              else
                echo "📝 Simulating API call (no key provided)"
                echo "Would send: 'Build-time telemetry from hash $BUNDLE_HASH'"
              fi
              
              echo ""
              echo "🎯 BUILD-TIME TELEMETRY CAPTURE COMPLETE!"
              
            } 2>&1 | tee $out/logs/build-time-capture.log
            
            # Create structured telemetry
            BUNDLE_HASH="$(basename ${gemini-cli.packages.${system}.default} | cut -d'-' -f1)"
            cat > $out/telemetry/build-time.json << EOF
            {
              "capture_type": "build_time_api_call",
              "timestamp": "$(date -Iseconds)", 
              "build_context": "nix_derivation_build_phase",
              "bundle_hash": "$BUNDLE_HASH",
              "bundle_size": $(stat -c%s ${gemini-cli.packages.${system}.default}/share/gemini-cli/bundle/gemini.js),
              "api_key_available": $([ -n "$GEMINI_API_KEY" ] && echo "true" || echo "false"),
              "gemini_calls_made": 3,
              "status": "completed_during_build"
            }
            EOF
          '';

          installPhase = ''
            echo "🎉 BUILD-TIME TELEMETRY INSTALLATION COMPLETE 🎉"
            echo "Telemetry captured during Nix build phase"
            echo "Results: $out/logs/build-time-capture.log"
            echo "JSON: $out/telemetry/build-time.json"
          '';
        };
      in
      {
        packages.default = buildTimeTelemetry;

        apps.default = {
          type = "app";
          program = "${pkgs.writeShellScript "show-build-telemetry" ''
            echo "=== BUILD-TIME TELEMETRY RESULTS ==="
            echo "Generated during: nix build --impure --extra-experimental-features impure-derivations"
            if [ -f ${buildTimeTelemetry}/logs/build-time-capture.log ]; then
              echo ""
              echo "Latest telemetry:"
              tail -15 ${buildTimeTelemetry}/logs/build-time-capture.log
              echo ""
              echo "JSON summary:"
              cat ${buildTimeTelemetry}/telemetry/build-time.json
            else
              echo "Run build first: nix build --impure --extra-experimental-features impure-derivations"
            fi
          ''}";
        };
      }
    );
}
