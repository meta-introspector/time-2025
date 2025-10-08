include ../../../../../../../../../../../../../scripts/nix_eval_module.mk


include scripts/nix_eval_module.mk


include ../../../scripts/nix_eval_module.mk


include 11662(python3 -c 'import os; print(os.path.relpath("/scripts", "./flakes/crq-document-check"))')/nix_eval_module.mk


include /nix_eval_module.mk


# Makefile for crq-document-check flake

.PHONY: build test

SYSTEM ?= aarch64-linux

build:
	@echo "--- Building crq-document-check-script ---"
	nix build .#packages.$(SYSTEM).crq-document-check-script
	@echo "--- Build Complete ---"

test:
	@echo "--- Testing crq-document-check-script ---"
	@COMMIT_MSG_FILE="$(CURDIR)/dummy_commit_msg.txt" \
	  nix run .#packages.$(SYSTEM).crq-document-check-script -- "$$COMMIT_MSG_FILE"
	@echo "--- Test Complete ---"

.PHONY: test-run-script
test-run-script:
	@echo "--- Testing run-crq-check.sh directly ---"
	@COMMIT_MSG_FILE="$(CURDIR)/dummy_commit_msg.txt" \
	  nix run .#packages.$(SYSTEM).run-crq-check-script -- \
	   --nixpkgs-path $(nix eval --raw .#nixpkgs) \
	   --crq-check-lib-path $(nix eval --raw .#crqCheckLib) \
	   --commit-msg-file "$$COMMIT_MSG_FILE"
	@echo "--- run-crq-check.sh Test Complete ---"

.PHONY: test-evaluate-script
test-evaluate-script:
	@echo "--- Testing evaluate-nix-expression.sh directly ---"
	@COMMIT_MSG_FILE="$(CURDIR)/dummy_commit_msg.txt" \
	  nix run .#packages.$(SYSTEM).evaluate-nix-expression-script -- \
	   --nixpkgs-path $(nix eval --raw .#nixpkgs) \
	   --crq-check-lib-path $(nix eval --raw .#crqCheckLib) \
	   --commit-msg-file "$$COMMIT_MSG_FILE"
	@echo "--- evaluate-nix-expression.sh Test Complete ---"

.PHONY: test-eval-script
test-eval-script:
	@echo "--- Testing eval-crq-check.sh directly ---"
	@NIXPKGS_PATH=$(nix eval --raw github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify) \
	 CRQ_CHECK_LIB_PATH=$(nix eval --raw ../../10/04/lib/crq-document-check.nix) \
	 COMMIT_MSG_FILE="$(CURDIR)/dummy_commit_msg.txt" \
	 $(nix build .#packages.$(SYSTEM).eval-crq-check-script --no-link --print-out-paths)/bin/eval-crq-check "$$NIXPKGS_PATH" "$$CRQ_CHECK_LIB_PATH" "$$COMMIT_MSG_FILE"
	@echo "--- eval-crq-check.sh Test Complete ---"

.PHONY: clean
clean:
	@echo "--- Cleaning up ---"
	@rm -f result
	@rm -f dummy_commit_msg.txt
	@echo "--- Cleanup Complete ---"

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


