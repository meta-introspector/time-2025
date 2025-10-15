NIX_FLAKE_ROOT := ../../..
ORCHESTRATOR_FLAKE_PATH := .

.PHONY: test
test:
	@echo "Building orchestrator flake default package..."
	@nix build .#packages.aarch64-linux.default
	@echo "Orchestrator flake default package built. Output in ./result/status-report.json"
