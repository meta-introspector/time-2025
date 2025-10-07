# Makefile for testing generate-base-flake-metadata.sh

.PHONY: test-generate-metadata

# Define sample environment variables for testing
TEST_FLAKE_NAME ?= test-base
TEST_DESCRIPTION ?= "A test description for the base flake."
TEST_SYSTEM ?= aarch64-linux
TEST_NIXPKGS_REF ?= 12345abc
TEST_FLAKE_UTILS_REF ?= 67890def
TEST_OUT_DIR ?= ./test_output

test-generate-metadata:
	@set -x; \
	echo "Testing generate-base-flake-metadata.sh..."; \
	mkdir -p $(TEST_OUT_DIR); \
	bash -c './generate-base-flake-metadata.sh --flake-name "$(TEST_FLAKE_NAME)" --description $(TEST_DESCRIPTION) --system "$(TEST_SYSTEM)" --nixpkgs-ref "$(TEST_NIXPKGS_REF)" --flake-utils-ref "$(TEST_FLAKE_UTILS_REF)" --out-dir "$(TEST_OUT_DIR)" '; \
	echo "\nContent of generated metadata.txt:"; \
	cat $(TEST_OUT_DIR)/metadata.txt; \
	echo "\nTest complete. Output in $(TEST_OUT_DIR)"

.PHONY: shellcheck
shellcheck:
	@echo "Running shellcheck on all bash scripts..."
	@shellcheck -x *.sh -e SC1091

.PHONY: clean-metadata-test
clean-metadata-test:
	@echo "Cleaning up metadata test output..."
	@rm -rf $(TEST_OUT_DIR)
	@echo "Cleanup complete."
