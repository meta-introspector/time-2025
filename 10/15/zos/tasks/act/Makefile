NIX_FLAKE_ROOT := ../../..
ACT_FLAKE_PATH := .

.PHONY: test
test:
	@echo "Evaluating act flake with dummy inputs..."
	@nix eval --raw $(ACT_FLAKE_PATH)#default --apply 'x: x { actionPlan = "dummy-action-plan"; dwimFlake = { lib = { aarch64-linux = { dwim = "/nix/store/dummy-dwim"; }; }; }; }' --no-write-lock-file
	@echo "Act flake test complete."
