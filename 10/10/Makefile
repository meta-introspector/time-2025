NIX_PATH := nixpkgs=$(HOME)/.nix-profile/share/nixpkgs

qa-llm-nix:
	@echo "Running QA for lib-llm-nix..."
	@nix-instantiate --eval --strict ./lib-llm-nix/qa.nix

run-qa-build:
	@echo "Running Nix build for QA and capturing output..."
	@bash ./run-qa-build.sh

lint-nix-impure:
	@echo "Running impure Nix linting with statix..."
	@nix shell nixpkgs#statix -c statix check ../../..

.PHONY: qa-llm-nix run-qa-build lint-nix-impure
