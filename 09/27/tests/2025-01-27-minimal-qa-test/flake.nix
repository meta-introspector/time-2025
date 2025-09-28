{
  description = "Minimal QA test to reproduce gemini-cli Nix build error and collect diagnostic logs";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    gemini-cli.url = "github:meta-introspector/gemini-cli?ref=feature/test";
  };

  outputs = { self, nixpkgs, flake-utils, gemini-cli }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Minimal diagnostic derivation
        minimalQATest = pkgs.stdenv.mkDerivation {
          pname = "gemini-cli-minimal-qa";
          version = "2025-01-27";
          src = gemini-cli;

          buildInputs = [ pkgs.nodejs_22 ];

          # Diagnostic build phase - collect all relevant info
          buildPhase = ''
            echo "=== Minimal QA Test for Gemini CLI - $(date) ==="
            
            # Create output structure
            mkdir -p $out/{diagnostics,logs,analysis}
            
            # 1. Source Analysis
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
                fi
              else
                echo "❌ Bundle directory NOT found" | tee -a $out/diagnostics/source_analysis.txt
                echo "Searching for .js files:" | tee -a $out/diagnostics/source_analysis.txt
                find "$src" -name "*.js" | head -10 | tee -a $out/diagnostics/source_analysis.txt
              fi
            else
              echo "❌ Source directory not accessible" | tee -a $out/diagnostics/source_analysis.txt
            fi
            
            # 2. Environment Analysis  
            echo "=== ENVIRONMENT ANALYSIS ===" | tee $out/diagnostics/environment.txt
            echo "Node.js: $(node --version)" | tee -a $out/diagnostics/environment.txt
            echo "NPM: $(npm --version 2>/dev/null || echo 'not available')" | tee -a $out/diagnostics/environment.txt
            echo "Shell: $SHELL" | tee -a $out/diagnostics/environment.txt
            echo "User: $(whoami)" | tee -a $out/diagnostics/environment.txt
            echo "System: $(uname -a)" | tee -a $out/diagnostics/environment.txt
            echo "Nix Store: $NIX_STORE" | tee -a $out/diagnostics/environment.txt
            echo "" | tee -a $out/diagnostics/environment.txt
            
            # 3. Path Resolution Test
            echo "=== PATH RESOLUTION TEST ===" | tee $out/diagnostics/path_resolution.txt
            echo "Attempting to resolve source paths..." | tee -a $out/diagnostics/path_resolution.txt
            
            # Test different path approaches
            echo "Direct source access:" | tee -a $out/diagnostics/path_resolution.txt
            ls "$src" >/dev/null 2>&1 && echo "✅ Source accessible" || echo "❌ Source NOT accessible" | tee -a $out/diagnostics/path_resolution.txt
            
            echo "Bundle path test:" | tee -a $out/diagnostics/path_resolution.txt
            ls "$src/bundle" >/dev/null 2>&1 && echo "✅ Bundle accessible" || echo "❌ Bundle NOT accessible" | tee -a $out/diagnostics/path_resolution.txt
            
            echo "Gemini.js path test:" | tee -a $out/diagnostics/path_resolution.txt
            ls "$src/bundle/gemini.js" >/dev/null 2>&1 && echo "✅ gemini.js accessible" || echo "❌ gemini.js NOT accessible" | tee -a $out/diagnostics/path_resolution.txt
            
            # 4. Minimal Execution Test (if possible)
            if [ -f "$src/bundle/gemini.js" ]; then
              echo "=== MINIMAL EXECUTION TEST ===" | tee $out/diagnostics/execution_test.txt
              echo "Testing basic gemini.js execution..." | tee -a $out/diagnostics/execution_test.txt
              
              # Copy to local location for testing
              cp "$src/bundle/gemini.js" "$out/gemini.js"
              chmod +x "$out/gemini.js"
              
              # Test basic execution (with timeout)
              echo "Running: node $out/gemini.js --help" | tee -a $out/diagnostics/execution_test.txt
              if timeout 10 node "$out/gemini.js" --help > $out/logs/help_test.log 2>&1; then
                echo "✅ Help command executed" | tee -a $out/diagnostics/execution_test.txt
              else
                EXIT_CODE=$?
                echo "ℹ️  Help command exit code: $EXIT_CODE" | tee -a $out/diagnostics/execution_test.txt
              fi
              
              # Test version
              echo "Running: node $out/gemini.js --version" | tee -a $out/diagnostics/execution_test.txt
              if timeout 10 node "$out/gemini.js" --version > $out/logs/version_test.log 2>&1; then
                echo "✅ Version command executed" | tee -a $out/diagnostics/execution_test.txt
              else
                EXIT_CODE=$?
                echo "ℹ️  Version command exit code: $EXIT_CODE" | tee -a $out/diagnostics/execution_test.txt
              fi
            else
              echo "=== EXECUTION TEST SKIPPED ===" | tee $out/diagnostics/execution_test.txt
              echo "gemini.js not found - cannot test execution" | tee -a $out/diagnostics/execution_test.txt
            fi
            
            # 5. Generate Summary Report
            echo "=== QA TEST SUMMARY ===" | tee $out/analysis/summary.txt
            echo "Timestamp: $(date -Iseconds)" | tee -a $out/analysis/summary.txt
            echo "Test: Minimal Gemini CLI QA" | tee -a $out/analysis/summary.txt
            echo "Source: $src" | tee -a $out/analysis/summary.txt
            echo "" | tee -a $out/analysis/summary.txt
            
            echo "Diagnostic Files Created:" | tee -a $out/analysis/summary.txt
            find $out -type f | sort | tee -a $out/analysis/summary.txt
            
            echo "" | tee -a $out/analysis/summary.txt
            echo "Key Findings:" | tee -a $out/analysis/summary.txt
            echo "- Source accessible: $([ -d "$src" ] && echo "YES" || echo "NO")" | tee -a $out/analysis/summary.txt
            echo "- Bundle exists: $([ -d "$src/bundle" ] && echo "YES" || echo "NO")" | tee -a $out/analysis/summary.txt
            echo "- gemini.js exists: $([ -f "$src/bundle/gemini.js" ] && echo "YES" || echo "NO")" | tee -a $out/analysis/summary.txt
            
            echo ""
            echo "✅ Minimal QA test completed - all diagnostics captured"
          '';

          installPhase = ''
            echo "Installation phase - creating test runner"
            
            # Create executable test runner
            mkdir -p $out/bin
            cat > $out/bin/qa-report << 'EOF'
#!/usr/bin/env bash
echo "=== Gemini CLI Minimal QA Report ==="
echo "Generated: $(date)"
echo ""

RESULT_PATH="$1"
if [ -z "$RESULT_PATH" ]; then
  echo "Usage: $0 <result-path>"
  echo "Run with: nix build --no-link --print-out-paths | xargs $0"
  exit 1
fi

if [ -f "$RESULT_PATH/analysis/summary.txt" ]; then
  cat "$RESULT_PATH/analysis/summary.txt"
else
  echo "Summary not found at: $RESULT_PATH/analysis/summary.txt"
fi

echo ""
echo "=== Detailed Diagnostics ==="
for file in "$RESULT_PATH/diagnostics"/*.txt; do
  if [ -f "$file" ]; then
    echo "--- $(basename "$file") ---"
    head -20 "$file"
    echo ""
  fi
done

echo "=== Log Files ==="
ls -la "$RESULT_PATH/logs/" 2>/dev/null || echo "No logs directory"
EOF
            chmod +x $out/bin/qa-report
            
            echo "✅ QA test installation complete"
          '';

          meta = {
            description = "Minimal QA test for Gemini CLI build diagnostics";
            license = pkgs.lib.licenses.mit;
          };
        };

      in
      {
        packages.default = minimalQATest;
        
        apps.default = {
          type = "app";
          program = "${pkgs.writeShellScript "run-minimal-qa" ''
            echo "=== Running Minimal Gemini CLI QA Test ==="
            RESULT=$(nix build --no-link --print-out-paths ${self.packages.${system}.default})
            echo "QA test completed at: $RESULT"
            echo ""
            exec $RESULT/bin/qa-report "$RESULT"
          ''}";
        };
      }
    );
}