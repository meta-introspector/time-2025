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
