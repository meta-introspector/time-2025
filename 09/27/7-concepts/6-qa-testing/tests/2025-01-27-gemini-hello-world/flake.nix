{
  description = "Hello World test for Gemini CLI - builds a derivation that calls gemini and captures output (2025-01-27)";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    gemini-cli.url = "github:meta-introspector/gemini-cli?ref=feature/working-gemini-cli-nix-store";
  };

  outputs = { self, nixpkgs, flake-utils, gemini-cli }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Test derivation that builds and calls gemini CLI
        geminiHelloWorldTest = pkgs.stdenv.mkDerivation {
          pname = "gemini-hello-world-test";
          version = "2025-01-27";
          src = gemini-cli;

          buildInputs = [
            pkgs.nodejs_22
          ];

          # Build phase - tests gemini CLI execution and captures output
          buildPhase = ''
            echo "=== Gemini CLI Hello World Test - 2025-01-27 ==="
            echo "Test started: $(date)"
            echo "Source directory: $src"
            echo "PWD: $(pwd)"
            echo "Node version: $(node --version)"
            echo ""

            # Create output directory structure (additive approach)
            mkdir -p $out/{test-results,bin,logs,artifacts,diagnostics}

            # 1. Source Analysis (from minimal-qa-test)
            echo "=== SOURCE ANALYSIS ===" | tee $out/diagnostics/source_analysis.txt
            echo "Source path: $src" | tee -a $out/diagnostics/source_analysis.txt
            echo "PWD: $(pwd)" | tee -a $out/diagnostics/source_analysis.txt
            echo "" | tee -a $out/diagnostics/source_analysis.txt
            
            # Check source structure
            echo "Source directory contents:" | tee -a $out/diagnostics/source_analysis.txt
            if [ -d "$src" ]; then
              ls -la "$src" | tee -a $out/diagnostics/source_analysis.txt
              echo "" | tee -a $out/diagnostics/source_analysis.txt
              
              # Check for bundle directory
              if [ -d "$src/bundle" ]; then
                echo "Bundle directory found:" | tee -a $out/diagnostics/source_analysis.txt
                ls -la "$src/bundle" | tee -a $out/diagnostics/source_analysis.txt
                
                # Check if gemini.js exists
                if [ -f "$src/bundle/gemini.js" ]; then
                  echo "✅ gemini.js found" | tee -a $out/diagnostics/source_analysis.txt
                  echo "Size: $(stat -c%s "$src/bundle/gemini.js") bytes" | tee -a $out/diagnostics/source_analysis.txt
                  echo "Permissions: $(stat -c%A "$src/bundle/gemini.js")" | tee -a $out/diagnostics/source_analysis.txt
                else
                  echo "❌ gemini.js NOT found" | tee -a $out/diagnostics/source_analysis.txt
                  echo "Searching for .js files:" | tee -a $out/diagnostics/source_analysis.txt
                  find "$src" -name "*.js" | head -10 | tee -a $out/diagnostics/source_analysis.txt
                  exit 1 # Exit if gemini.js is not found, as it's critical for the test
                fi
              else
                echo "❌ Bundle directory NOT found" | tee -a $out/diagnostics/source_analysis.txt
                echo "Searching for .js files:" | tee -a $out/diagnostics/source_analysis.txt
                find "$src" -name "*.js" | head -10 | tee -a $out/diagnostics/source_analysis.txt
                exit 1 # Exit if bundle directory is not found
              fi
            else
              echo "❌ Source directory not accessible" | tee -a $out/diagnostics/source_analysis.txt
              exit 1 # Exit if source directory is not accessible
            fi
            echo ""
            
            # 3. Path Resolution Test (from minimal-qa-test)
            echo "=== PATH RESOLUTION TEST ===" | tee -a $out/diagnostics/path_resolution.txt
            echo "Attempting to resolve source paths..." | tee -a $out/diagnostics/path_resolution.txt
            
            # Test different path approaches
            echo "Direct source access:" | tee -a $out/diagnostics/path_resolution.txt
            ls "$src" >/dev/null 2>&1 && echo "✅ Source accessible" || (echo "❌ Source NOT accessible" | tee -a $out/diagnostics/path_resolution.txt && exit 1)
            
            echo "Bundle path test:" | tee -a $out/diagnostics/path_resolution.txt
            ls "$src/bundle" >/dev/null 2>&1 && echo "✅ Bundle accessible" || (echo "❌ Bundle NOT accessible" | tee -a $out/diagnostics/path_resolution.txt && exit 1)
            
            echo "Gemini.js path test:" | tee -a $out/diagnostics/path_resolution.txt
            ls "$src/bundle/gemini.js" >/dev/null 2>&1 && echo "✅ gemini.js accessible" || (echo "❌ gemini.js NOT accessible" | tee -a $out/diagnostics/path_resolution.txt && exit 1)
            echo ""

            # Copy gemini.js to our output for testing (additive)
            cp "$src/bundle/gemini.js" "$out/bin/gemini.js"
            chmod +x "$out/bin/gemini.js"
            echo "✅ Copied gemini.js to $out/bin/gemini.js"
            echo ""

            # Test 1: Help command

            # Copy gemini.js to our output for testing (additive)
            cp "$src/bundle/gemini.js" "$out/bin/gemini.js"
            chmod +x "$out/bin/gemini.js"
            echo "✅ Copied gemini.js to $out/bin/gemini.js"
            echo ""

            # Test 1: Help command
            echo "=== Test 1: Help Command ==="
            echo "Running: node $out/bin/gemini.js --help"
            if timeout 30 node "$out/bin/gemini.js" --help > "$out/test-results/help_output.txt" 2>&1; then
              echo "✅ Help command completed (exit code: $?)"
            else
              EXIT_CODE=$?
              echo "ℹ️  Help command returned exit code: $EXIT_CODE (captured)"
            fi
            echo ""

            # Test 2: Version command
            echo "=== Test 2: Version Command ==="
            echo "Running: node $out/bin/gemini.js --version"
            if timeout 30 node "$out/bin/gemini.js" --version > "$out/test-results/version_output.txt" 2>&1; then
              echo "✅ Version command completed"
            else
              EXIT_CODE=$?
              echo "ℹ️  Version command returned exit code: $EXIT_CODE (captured)"
            fi
            echo ""

            # Test 3: Basic execution without API key (expected to show error)
            echo "=== Test 3: Basic Execution Test ==="
            echo "Running: node $out/bin/gemini.js 'hello world'"
            if timeout 30 node "$out/bin/gemini.js" "hello world" > "$out/test-results/hello_output.txt" 2>&1; then
              echo "✅ Basic execution completed"
            else
              EXIT_CODE=$?
              echo "ℹ️  Basic execution returned exit code: $EXIT_CODE (expected without API key)"
            fi
            echo ""

            # Test 4: No arguments test
            echo "=== Test 4: No Arguments Test ==="
            echo "Running: node $out/bin/gemini.js"
            if timeout 30 node "$out/bin/gemini.js" > "$out/test-results/no_args_output.txt" 2>&1; then
              echo "✅ No arguments test completed"
            else
              EXIT_CODE=$?
              echo "ℹ️  No arguments test returned exit code: $EXIT_CODE (captured)"
            fi
            echo ""

            # Create comprehensive summary (additive documentation)
            echo "=== Generating Test Summary ==="
            {
              echo "=== Gemini CLI Hello World Test Summary ==="
              echo "Test Date: $(date)"
              echo "Test Version: 2025-01-27"
              echo "Node.js Version: $(node --version)"
              echo "Gemini.js Size: $(stat -c%s "$out/bin/gemini.js") bytes"
              echo "Source Path: $src"
              echo "Output Path: $out"
              echo ""
              echo "=== Test Results ==="
              echo "1. Help Command: $([ -f "$out/test-results/help_output.txt" ] && echo "✅ Captured" || echo "❌ Failed")"
              echo "2. Version Command: $([ -f "$out/test-results/version_output.txt" ] && echo "✅ Captured" || echo "❌ Failed")"
              echo "3. Hello World: $([ -f "$out/test-results/hello_output.txt" ] && echo "✅ Captured" || echo "❌ Failed")"
              echo "4. No Arguments: $([ -f "$out/test-results/no_args_output.txt" ] && echo "✅ Captured" || echo "❌ Failed")"
              echo ""
              echo "=== File Outputs ==="
              ls -la "$out/test-results/"
              echo ""
              echo "=== Output Previews ==="
              echo "--- Help Output (first 5 lines) ---"
              head -5 "$out/test-results/help_output.txt" 2>/dev/null || echo "No help output"
              echo "--- Version Output ---"
              cat "$out/test-results/version_output.txt" 2>/dev/null || echo "No version output"
              echo "--- Hello World Output (first 5 lines) ---"
              head -5 "$out/test-results/hello_output.txt" 2>/dev/null || echo "No hello output"
            echo "Diagnostic Files Created:" | tee -a $out/analysis/summary.txt
            find $out -type f | sort | tee -a $out/analysis/summary.txt
            echo "" | tee -a $out/analysis/summary.txt
            echo "=== Diagnostic Files ===" | tee -a $out/analysis/summary.txt
            cat $out/diagnostics/source_analysis.txt | tee -a $out/analysis/summary.txt
            cat $out/diagnostics/path_resolution.txt | tee -a $out/analysis/summary.txt

            # Copy summary to logs for external access
            cp "$out/test-results/summary.txt" "$out/logs/test-summary-$(date +%Y%m%d-%H%M%S).txt"

            echo "✅ Test summary generated"
            echo "=== Build Phase Complete ==="
          '';

          installPhase = ''
                        # Create executable test runner (additive approach)
                        cat > $out/bin/run-test-report.sh << 'EOF'
            #!/bin/bash
            echo "=== Gemini CLI Hello World Test Report ==="
            echo "Report generated: $(date)"
            echo ""

            if [ -f "$1/test-results/summary.txt" ]; then
              cat "$1/test-results/summary.txt"
            else
              echo "Summary not found at: $1/test-results/summary.txt"
              echo "Available files:"
              find "$1" -type f 2>/dev/null || echo "No files found"
            fi

            echo ""
            echo "=== Detailed Outputs Available ==="
            echo "Help: $1/test-results/help_output.txt"
            echo "Version: $1/test-results/version_output.txt" 
            echo "Hello: $1/test-results/hello_output.txt"
            echo "No Args: $1/test-results/no_args_output.txt"
            EOF
                        chmod +x $out/bin/run-test-report.sh

                        # Create artifact manifest (permanent record)
                        cat > $out/artifacts/manifest.json << EOF
            {
              "test_name": "gemini-hello-world",
              "test_date": "2025-01-27",
              "test_version": "1.0.0",
              "gemini_cli_source": "$src",
              "node_version": "$(node --version)",
              "created_files": [
                "bin/gemini.js",
                "bin/run-test-report.sh",
                "test-results/summary.txt",
                "test-results/help_output.txt",
                "test-results/version_output.txt",
                "test-results/hello_output.txt",
                "test-results/no_args_output.txt",
                "logs/test-summary-*.txt",
                "artifacts/manifest.json",
                "diagnostics/source_analysis.txt",
                "diagnostics/path_resolution.txt"
              ],
              "build_timestamp": "$(date -Iseconds)"
            }
            EOF

                        echo "✅ Test derivation installation complete"
                        echo "Available artifacts:"
                        find $out -type f | sort
          '';

          meta = {
            description = "Comprehensive hello world test for Gemini CLI with captured outputs";
            license = pkgs.lib.licenses.mit;
          };
        };

        # Test execution wrapper (additive approach)
        testExecutor = pkgs.writeShellScript "gemini-hello-world-executor" ''
          echo "=== Gemini Hello World Test Executor - 2025-01-27 ==="
          echo "Building test derivation..."
          
          # Build and get result path
          RESULT_PATH=$(nix build --no-link --print-out-paths ${self.packages.${system}.default})
          
          if [ -n "$RESULT_PATH" ] && [ -d "$RESULT_PATH" ]; then
            echo "✅ Test built successfully at: $RESULT_PATH"
            echo ""
            
            # Execute the test report
            exec "$RESULT_PATH/bin/run-test-report.sh" "$RESULT_PATH"
          else
            echo "❌ Test build failed or result path not found"
            exit 1
          fi
        '';

      in
      {
        packages.default = geminiHelloWorldTest;

        apps.default = {
          type = "app";
          program = testExecutor;
        };

        # Development shell for manual testing
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.nodejs_22
          ];

          shellHook = ''
            echo "=== Gemini Hello World Test Environment - 2025-01-27 ==="
            echo "Available commands:"
            echo "  nix build    : Build the test derivation"
            echo "  nix run      : Execute complete test and show report"
            echo "  node --version : $(node --version)"
            echo ""
            echo "Test follows NEVER DELETE principle - all outputs preserved"
          '';
        };
      }
    );
}
