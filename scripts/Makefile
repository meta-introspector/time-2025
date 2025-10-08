include ../../../../../../../../../../../../scripts/nix_eval_module.mk


include scripts/nix_eval_module.mk


include ../../scripts/nix_eval_module.mk


include 11662(python3 -c 'import os; print(os.path.relpath("/scripts", "./scripts"))')/nix_eval_module.mk


include /nix_eval_module.mk


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

.PHONY: develop.log

develop.log: flake.nix
	@echo "--- Running nix develop for 7720(pwd) and logging output to develop.log ---"
	@nix develop --command echo "Successfully entered develop shell for 7720(pwd)" > develop.log 2>&1 || { 		echo "ERROR: nix develop failed for 7720(pwd). Check develop.log for details."
		cat develop.log; 		exit 1; 	}
	@echo "--- develop.log created for 7720(pwd) ---"

# TODO: Add dependencies on flake inputs here. This might require parsing flake.lock or evaluating the flake.


.PHONY: test-uncommitted

test-uncommitted: uncommitted.nix
	@echo "--- Testing uncommitted.nix with nix eval ---"
	@nix eval --raw ./uncommitted.nix > uncommitted.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for uncommitted.nix. Check uncommitted.eval.log for details."
		cat uncommitted.eval.log; 		exit 1; 	}
	@echo "--- uncommitted.nix test complete. Output in uncommitted.eval.log ---"


