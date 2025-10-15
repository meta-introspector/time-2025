NIX_FLAKE_ROOT := ../../..
DECIDE_FLAKE_PATH := .

.PHONY: test
test:
	@echo "Evaluating decide flake with dummy inputs..."
	@nix eval --raw $(DECIDE_FLAKE_PATH)#default --apply 'x: x { orientationDecision = "dummy-orientation"; }' --no-write-lock-file
	@echo "Decide flake test complete."
