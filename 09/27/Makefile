# QA Makefile for Gemini CLI Nix Integration
# All complex shell operations should be defined here

.PHONY: help clean test-minimal test-gemini fix-build check-deps

# Default target
help:
	@echo "QA Makefile for Gemini CLI Nix Integration"
	@echo "Available targets:"
	@echo "  check-deps    - Verify all dependencies are available"
	@echo "  fix-build     - Fix the current build issues"
	@echo "  test-minimal  - Run minimal QA test"
	@echo "  test-gemini   - Run Gemini CLI telemetry capture"
	@echo "  clean         - Clean up build artifacts"

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

# Validate flake syntax
validate-flake:
	@echo "=== Validating Flake Syntax ==="
	./scripts/validate-flake.sh tests/2025-01-27-gemini-telemetry-capture-v2/flake.nix

# Run comprehensive tests
test-all: check-deps test-minimal validate-flake test-gemini
	@echo "=== All Tests Complete ==="