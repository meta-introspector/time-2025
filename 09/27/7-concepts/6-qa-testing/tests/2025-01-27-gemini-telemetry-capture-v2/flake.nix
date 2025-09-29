{
  description = "Gemini CLI telemetry capture - syntax fixed";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    gemini-cli.url = "github:meta-introspector/gemini-cli?ref=feature/working-gemini-cli-nix-store";
  };

  outputs = { self, nixpkgs, flake-utils, gemini-cli }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Simple test script that avoids complex shell quoting
        testScript = pkgs.writeShellScript "test-gemini" ''
          #!/usr/bin/env bash
          set -e
          
          echo "=== Gemini CLI Test Started ==="
          echo "Timestamp: $(date -Iseconds)"
          echo "Node version: $(node --version)"
          echo "PWD: $(pwd)"
          
          # Check API key status
          if [ -n "$GEMINI_API_KEY" ]; then
            echo "GEMINI_API_KEY: SET (''${#GEMINI_API_KEY} chars)"
          else
            echo "GEMINI_API_KEY: NOT SET"
          fi
          
          # Check source structure
          echo "Source contents:"
          ls -la "$1"
          
          if [ -f "$1/bundle/gemini.js" ]; then
            echo "✓ Found gemini.js"
            cp "$1/bundle/gemini.js" ./gemini.js
            chmod +x ./gemini.js
            
            echo "Testing --help:"
            timeout 30 node ./gemini.js --help || echo "Help exit code: $?"
            
            echo "Testing hello world:"
            timeout 30 node ./gemini.js "hello world" || echo "Prompt exit code: $?"
            
            echo "✓ Gemini CLI tests completed"
          else
            echo "✗ gemini.js not found"
            exit 1
          fi
        '';

        geminiTest = pkgs.stdenv.mkDerivation {
          pname = "gemini-test";
          version = "1.0";
          src = gemini-cli;

          __impure = true;

          buildInputs = [ pkgs.nodejs_22 pkgs.strace ];

          GEMINI_API_KEY = builtins.getEnv "GEMINI_API_KEY";

          buildPhase = ''
            echo "=== Build Phase Started ==="
            
            mkdir -p $out/{logs,traces,analysis}
            
            # Use the external script to avoid quoting issues
            ${testScript} "$src" | tee $out/logs/test-output.log
            
            echo "=== Build Phase Complete ==="
          '';

          installPhase = ''
            echo "Installation complete"
          '';
        };
      in
      {
        packages.default = geminiTest;

        apps.default = {
          type = "app";
          program = "${testScript}";
        };
      }
    );
}
