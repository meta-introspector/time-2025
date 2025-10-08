include ../../../../../../../../../../../../../../scripts/nix_eval_module.mk


include scripts/nix_eval_module.mk


include ../../../../scripts/nix_eval_module.mk


include 11662(python3 -c 'import os; print(os.path.relpath("/scripts", "./flakes/crq-search-lattice/parser"))')/nix_eval_module.mk


include /nix_eval_module.mk


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



.PHONY: test-default

test-default: default.nix
	@echo "--- Testing default.nix with nix eval ---"
	@nix eval --raw ./default.nix > default.eval.log 2>&1 || { 		echo "ERROR: nix eval failed for default.nix. Check default.eval.log for details."
		cat default.eval.log; 		exit 1; 	}
	@echo "--- default.nix test complete. Output in default.eval.log ---"


