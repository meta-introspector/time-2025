NIX_PATH := nixpkgs=$(HOME)/.nix-profile/share/nixpkgs

build-example-verbose:
	@echo "Building example flake with verbose output to example_build.log..."
	@nix build -vvvvv ./nix2/examples#packages.aarch64-linux.default 2>&1 | tee example_build.log

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

build-nar-verbose:
	@echo "Building NAR flake with verbose output to nar_build.log..."
	@nix build -vv "github:meta-introspector/time-2025?ref=feature/git-nix-file-list&dir=10/10/lib/nar#packages.aarch64-linux.default" 2>&1 | tee nar_build.log

.PHONY: qa-llm-nix run-qa-build get-nix-file-list build-nar-verbose build-example-verbose
