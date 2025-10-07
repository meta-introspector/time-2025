{
  description = "Build-time Gemini telemetry capture - calls Gemini during Nix build";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    sops-nix.url = "github:meta-introspector/sops-nix?ref=feature/working-gemini-cli-nix-store";
    # Use our local working gemini-cli with confirmed bundle in Nix store

  };

  outputs = { self, nixpkgs, flake-utils } @ inputs:
    let
      eachSystem = flake-utils.lib.eachDefaultSystem;
    in
    eachSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (nixpkgs) lib;

        # Import the secrets definition
        secretsConfig = import ./secrets.nix { inherit pkgs lib; };

        # Derivation to decrypt sops secrets
        decryptedSopsSecrets = pkgs.stdenv.mkDerivation {
          pname = "decrypted-sops-secrets";
          version = "1.0";
          
          # The sops-nix module needs to be applied to a configuration
          # For a simple derivation, we can use `pkgs.writeText` to create a dummy configuration
          # and then use `pkgs.lib.evalModules` to evaluate it with sops-nix.
          # However, a simpler approach for `mkDerivation` is to use `sops` directly.
          # For now, we'll assume the secrets are already decrypted and available via `sops-nix`'s mechanism
          # and focus on how to access them. This part will be refined.
          
          # For now, let's assume sops-nix provides a way to get the decrypted paths
          # This is a placeholder and will be replaced with actual sops-nix integration
          # once the overall structure is in place.
          
          # This derivation will simply create dummy files for now, to allow the flake to build.
          # The actual decryption logic will be added later.
          buildPhase = ''
            mkdir -p $out/.gemini
            ${pkgs.sops}/bin/sops -d ./sops-secrets/oauth_creds.json > $out/.gemini/oauth_creds.json
            ${pkgs.sops}/bin/sops -d ./sops-secrets/settings.json > $out/.gemini/settings.json
            ${pkgs.sops}/bin/sops -d ./sops-secrets/google_accounts.json > $out/.gemini/google_accounts.json
          '';
          
          # Add sops as a build input if direct sops command is used
          buildInputs = [ pkgs.sops ];
        };

        flakeNixContent = builtins.readFile (self + "/flake.nix");

        # Define the script that captures telemetry
        buildTimeTelemetry = pkgs.stdenv.mkDerivation {
          pname = "build-time-gemini-telemetry";
          version = "1.0";

          src = pkgs.writeText "dummy" "build telemetry";
          dontUnpack = true;

          __impure = true;

          buildInputs = [
            pkgs.nodejs_22
            pkgs.jq
            pkgs.curl
#            pkgs.strace # Added strace for build-time telemetry
            pkgs.cacert # Added cacert for SSL/TLS certificate verification
            gemini-cli.packages.${system}.default
            decryptedSopsSecrets # Add the derivation that decrypts sops secrets
          ];

          FLAKE_NIX_CONTENT = flakeNixContent; # Pass the content here

          # Environment variables for build
          NIX_BUILD_TELEMETRY = "true";

          buildPhase = ''
            echo "🔥 BUILD-TIME GEMINI TELEMETRY CAPTURE 🔥"
	    find .
	    pwd
	    #	    ls -latr /creds/google_accounts.json || echo skip

	    #~/.gemini/google_accounts.json
            # Set HOME to a writable temporary directory for gemini-cli 
            export HOME=$(mktemp -d)
            trap 'rm -rf "$HOME"' EXIT
	    mkdir -p logs # for gemmin
            mkdir -p $out/{logs,telemetry,analysis}
            
            # Credential files are now available via decryptedSopsSecrets
            echo "✅ Decrypted credentials available from decryptedSopsSecrets"
            echo "=== Contents of decryptedSopsSecrets BEFORE copy ==="
	    #find .
	    #pwd
	    #find / || echo error
            echo "======================================="
            mkdir -p $HOME/.gemini/
            cp ${decryptedSopsSecrets}/.gemini/settings.json $HOME/.gemini/
	    cp ${decryptedSopsSecrets}/.gemini/oauth_creds.json $HOME/.gemini/
   	    cp ${decryptedSopsSecrets}/.gemini/google_accounts.json $HOME/.gemini/
            echo "✅ Copied credential files from decryptedSopsSecrets to $HOME/.gemini/"
            echo ""
            echo "=== Contents of $HOME/.gemini/ ==="
            ls -latr $HOME/.gemini/
            echo "=================================="

            # Capture build environment
            {
	      md5sum $HOME/.gemini/*
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
              
              # Credential files check
              OAUTH_CREDS_FILE="$HOME/.gemini/oauth_creds.json"
              SETTINGS_FILE="$HOME/.gemini/settings.json"
              GOOGLE_ACCOUNTS_FILE="$HOME/.gemini/google_accounts.json"

              WILL_CALL_API="false"
              if [ -f "$OAUTH_CREDS_FILE" ]; then
                echo "🔑 OAuth credentials file found: $OAUTH_CREDS_FILE $(md5sum $OAUTH_CREDS_FILE)"
                WILL_CALL_API="true"
              fi
              if [ -f "$SETTINGS_FILE" ]; then
                echo "🔑 Settings file found: $SETTINGS_FILE $(md5sum $SETTINGS_FILE)"
                WILL_CALL_API="true"
              fi
              if [ -f "$GOOGLE_ACCOUNTS_FILE" ]; then
                echo "🔑 Google accounts file found: $GOOGLE_ACCOUNTS_FILE $(md5sum $GOOGLE_ACCOUNTS_FILE)"
                WILL_CALL_API="true"
              fi

              if [ "$WILL_CALL_API" = "true" ]; then
                echo "✅ At least one credential file found. API calls enabled."
              else
                echo "❌ No credential files found in $HOME/.gemini/ (test mode). API calls simulated."
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
                #if timeout 120
		                #strace -f -o logs/strace
		"$WRAPPER_PATH" --debug --output-format json --approval-mode yolo --model gemini-2.5-flash --prompt "I am calling you from INSIDE a Nix build derivation! This is real-time telemetry capture. Bundle hash: $BUNDLE_HASH. Time: $(date) Please read flake.nix, and modify it to read @task.md for more instructions. If you cant read flake.nix write a nix package that adds flake.nix, task.md and mission.md to the output. then add a report of the telemetry log via another rust crate and another derivation. we want to create multiple derviations from one task, a whole lattice of them."
              else
                echo "📝 Simulating API call (no key provided)"
                echo "Would send: 'Build-time telemetry from hash $BUNDLE_HASH'"
              fi
              
              echo ""
              echo "🎯 BUILD-TIME TELEMETRY CAPTURE COMPLETE!"
              
            } 2>&1 | tee $out/logs/build-time-capture.log

	    # copy the telemetry
	    cp logs/* $out/logs/
	    
            # Create structured telemetry
            BUNDLE_HASH="$(basename ${gemini-cli.packages.${system}.default} | cut -d'-' -f1)"
            cat > $out/telemetry/build-time.json << EOF
            {
              "capture_type": "build_time_api_call",
              "timestamp": "$(date -Iseconds)", 
              "build_context": "nix_derivation_build_phase",
              "bundle_hash": "$BUNDLE_HASH",
              "bundle_size": $(stat -c%s ${gemini-cli.packages.${system}.default}/share/gemini-cli/bundle/gemini.js),
              "api_key_available": $([ -f "$HOME/.gemini/oauth_creds.json" ] || [ -f "$HOME/.gemini/settings.json" ] || [ -f "$HOME/.gemini/google_accounts.json" ] && echo "true" || echo "false"),
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
        nix.settings = {};
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
