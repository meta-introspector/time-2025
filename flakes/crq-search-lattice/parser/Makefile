# Makefile for the CRQ Parser Flake

.PHONY: test-parse-crq

# Define the system architecture
SYSTEM ?= aarch64-linux

# Define a sample filename for testing
TEST_FILENAME ?= CRQ_001_Log_Analysis_Pure_Derivation.md

# Target to test the parseCrqFilename function
test-parse-crq:
	@echo "Testing parseCrqFilename with: $(TEST_FILENAME)"
	@nix eval --impure --expr 'let flake = builtins.getFlake "path:$(CURDIR)"; in flake.lib.$(SYSTEM).parseCrqFilename "$(TEST_FILENAME)"' --json
	@echo "\nTo test with a different filename, run: make test-parse-crq TEST_FILENAME=\"CRQ_XXX_Your_Title.md\""
	@echo "To test with a different system, run: make test-parse-crq SYSTEM=x86_64-linux"

.PHONY: clean
clean:
	@echo "Cleaning up temporary files..."
	@rm -f default.nix
	@rm -f flake.lock
	@echo "Cleanup complete."
