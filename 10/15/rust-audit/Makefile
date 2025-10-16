NIX_FLAKE_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

.PHONY: run-audit
run-audit:
	@echo "Running Nix Auditor Rust tool..."
	@nix run $(NIX_FLAKE_DIR) -- \
		/data/data/com.termux.nix/files/home/nix/index/flake.lock.txt \
		/data/data/com.termux.nix/files/home/nix/index/flake.nix.store \
		$(NIX_FLAKE_DIR)/audit-report.json
	@echo "Audit report generated at $(NIX_FLAKE_DIR)/audit-report.json"
