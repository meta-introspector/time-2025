NIX_PATH := nixpkgs=$(HOME)/.nix-profile/share/nixpkgs

qa-llm-nix:
	@echo "Running QA for lib-llm-nix..."
	@nix-instantiate --eval --strict ./lib-llm-nix/qa.nix

run-qa-build:
	@echo "Running Nix build for QA and capturing output..."
	@bash ./run-qa-build.sh

get-nix-file-list:
	@echo "Generating list of Nix files..."
	@nix eval -f ./nix2/get-nix-file-list.nix --json > nix-file-list.json
	@echo "Nix file list generated: nix-file-list.json"

.PHONY: qa-llm-nix run-qa-build get-nix-file-list
