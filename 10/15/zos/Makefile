NIX_FLAKE_ROOT := ../../..
ORCHESTRATOR_FLAKE_PATH := .

.PHONY: test
test:
	@echo "Evaluating orchestrator flake..."
	@nix eval --raw $(ORCHESTRATOR_FLAKE_PATH)#default --no-write-lock-file
	@echo "Orchestrator flake test complete."
