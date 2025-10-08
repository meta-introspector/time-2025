include ../../../../../../../../../../../../../../../scripts/nix_eval_module.mk


include scripts/nix_eval_module.mk


include ../../../../../scripts/nix_eval_module.mk


include 11662(python3 -c 'import os; print(os.path.relpath("/scripts", "./09/27/7-concepts/1-build-system"))')/nix_eval_module.mk


include /nix_eval_module.mk


# QA Makefile for Gemini CLI Nix Integration
# All complex shell operations should be defined here

.PHONY: help clean test-minimal test-gemini fix-build check-deps inspect-vendor-gemini build-vendor-gemini check-bundle-js test-bundle-gemini test-vendor-nix

# Default target
help:
	@echo "QA Makefile for Gemini CLI Nix Integration"
	@echo "Available targets:"
	@echo "  check-deps         - Verify all dependencies are available"
	@echo "  fix-build          - Fix the current build issues"
	@echo "  test-minimal       - Run minimal QA test"
	@echo "  test-gemini        - Run Gemini CLI telemetry capture"
	@echo "  inspect-vendor-gemini - Inspect vendor gemini-cli structure"
	@echo "  build-vendor-gemini   - Build vendor gemini-cli with Nix (tries multiple approaches)"
	@echo "  check-bundle-js    - Check for bundle/gemini.js in results"
	@echo "  test-bundle-gemini - Test existing bundle/gemini.js directly"
	@echo "  test-vendor-nix    - Test vendor Nix builds and packages"
	@echo "  clean              - Clean up build artifacts"

# Check dependencies
check-deps:
	@echo "=== Checking Dependencies ==="
	@which nix || (echo "ERROR: nix not found"; exit 1)
	@which node || (echo "ERROR: node not found"; exit 1)
	@echo "✓ Basic dependencies available"

# Clean build artifacts
clean:
	@echo "=== Cleaning Build Artifacts ==="
	rm -rf logs/
	rm -rf telemetry-archives/
	rm -rf result*
	@echo "✓ Cleanup complete"

# Fix current build issues
fix-build:
	@echo "=== Fixing Build Issues ==="
	./scripts/fix-flake-syntax.sh
	@echo "✓ Build fixes applied"

# Run minimal QA test
test-minimal:
	@echo "=== Running Minimal QA Test ==="
	cd tests/2025-01-27-minimal-qa-test && nix build --show-trace

# Test Gemini CLI telemetry capture
test-gemini:
	@echo "=== Testing Gemini CLI Telemetry Capture ==="
	./scripts/test-gemini-build.sh

# Test working Gemini CLI from Nix store
test-gemini-working:
	@echo "=== Testing Working Gemini CLI from Nix Store ==="
	cd tests/2025-01-27-gemini-telemetry-capture-v3 && nix build --show-trace --impure

# Run working Gemini CLI app directly
run-gemini-working:
	@echo "=== Running Working Gemini CLI App ==="
	cd tests/2025-01-27-gemini-telemetry-capture-v3 && nix run .#gemini -- --version

# Test impure GitHub integration with telemetry capture
test-github-impure:
	@echo "=== Testing GitHub Impure Integration ==="
	cd tests/2025-01-27-github-gemini-impure && nix build --show-trace --impure

# Run GitHub impure Gemini integration
run-github-gemini:
	@echo "=== Running GitHub Gemini Integration ==="
	cd tests/2025-01-27-github-gemini-impure && nix run .#gemini -- "Hello from GitHub impure derivation!"

# Validate flake syntax
validate-flake:
	@echo "=== Validating Flake Syntax ==="
	./scripts/validate-flake.sh tests/2025-01-27-gemini-telemetry-capture-v2/flake.nix

# Inspect vendor gemini-cli structure
inspect-vendor-gemini:
	@echo "=== Inspecting Vendor Gemini CLI ==="
	@./scripts/inspect-nix-gemini-bundle.sh

# Build vendor gemini-cli with Nix (try different targets)
build-vendor-gemini:
	@echo "=== Building Vendor Gemini CLI ==="
	@mkdir -p logs
	@echo "Checking if bundle exists in vendor directory..."
	@ls -la ~/pick-up-nix2/vendor/external/gemini-cli/bundle/gemini.js || echo "Bundle not found"
	@echo "Trying default package build..."
	@cd ~/pick-up-nix2/vendor/external/gemini-cli && \
		nix build --show-trace 2>&1 | tee $(PWD)/logs/vendor-gemini-build.log || \
		echo "Default build completed (may have issues if bundle not in store)"
	@echo "Trying with-build package (builds bundle from source)..."
	@cd ~/pick-up-nix2/vendor/external/gemini-cli && \
		nix build .#gemini-cli-with-build --show-trace 2>&1 | tee -a $(PWD)/logs/vendor-gemini-build.log || \
		echo "With-build package failed"
	@echo "✓ Vendor build attempted - check logs for results"

# Check for bundle/gemini.js in Nix build results
check-bundle-js:
	@echo "=== Checking for bundle/gemini.js ==="
	@echo "In vendor directory:"
	@[ -f ~/pick-up-nix2/vendor/external/gemini-cli/bundle/gemini.js ] && \
		echo "✓ Found: ~/pick-up-nix2/vendor/external/gemini-cli/bundle/gemini.js" || \
		echo "✗ Missing: ~/pick-up-nix2/vendor/external/gemini-cli/bundle/gemini.js"
	@echo ""
	@echo "In Nix result (if exists):"
	@cd ~/pick-up-nix2/vendor/external/gemini-cli && \
		if [ -L result ]; then \
			echo "Nix result found: $$(readlink result)"; \
			find result -name "gemini.js" -type f 2>/dev/null || echo "No gemini.js in result"; \
			find result -name "bundle" -type d 2>/dev/null || echo "No bundle directory in result"; \
		else \
			echo "No Nix result symlink found"; \
		fi
	@echo "✓ Bundle check complete"

# Test existing bundle/gemini.js directly
test-bundle-gemini:
	@echo "=== Testing Bundle Gemini.js ==="
	@mkdir -p logs
	@if [ -f ~/pick-up-nix2/vendor/external/gemini-cli/bundle/gemini.js ]; then \
		echo "Testing gemini.js --help..."; \
		cd ~/pick-up-nix2/vendor/external/gemini-cli && \
			timeout 30 node bundle/gemini.js --help 2>&1 | tee $(PWD)/logs/gemini-help-test.log || \
			echo "Help test completed with exit code: $$?"; \
		echo "Testing gemini.js with simple prompt..."; \
		cd ~/pick-up-nix2/vendor/external/gemini-cli && \
			timeout 30 node bundle/gemini.js "Hello, test prompt" 2>&1 | tee $(PWD)/logs/gemini-prompt-test.log || \
			echo "Prompt test completed with exit code: $$?"; \
		echo "✓ Bundle tests completed - check logs/gemini-*-test.log"; \
	else \
		echo "✗ bundle/gemini.js not found"; \
	fi

# Test vendor Nix builds and packages
test-vendor-nix:
	@echo "=== Testing Vendor Nix Builds ==="
	@mkdir -p logs
	@cd ~/pick-up-nix2/vendor/external/gemini-cli && \
		echo "Using vendor Makefile to test..." && \
		make verify 2>&1 | tee $(PWD)/logs/vendor-nix-test.log
	@echo "✓ Vendor Nix tests completed - check logs/vendor-nix-test.log"

# Run comprehensive tests
test-all: check-deps inspect-vendor-gemini test-minimal validate-flake test-gemini test-bundle-gemini test-vendor-nix
	@echo "=== All Tests Complete ==="
.PHONY: develop.log

develop.log: flake.nix
	@echo "--- Running nix develop for 7720(pwd) and logging output to develop.log ---"
	@nix develop --command echo "Successfully entered develop shell for 7720(pwd)" > develop.log 2>&1 || { 		echo "ERROR: nix develop failed for 7720(pwd). Check develop.log for details."
		cat develop.log; 		exit 1; 	}
	@echo "--- develop.log created for 7720(pwd) ---"

# TODO: Add dependencies on flake inputs here. This might require parsing flake.lock or evaluating the flake.


.PHONY: test-flake

test-flake: flake.nix
	@echo "--- Testing flake.nix with nix eval ---"
	@nix eval --raw ./flake.nix > flake.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for flake.nix. Check flake.eval.log for details."
		cat flake.eval.log; 		exit 1; 	}
	@echo "--- flake.nix test complete. Output in flake.eval.log ---"


