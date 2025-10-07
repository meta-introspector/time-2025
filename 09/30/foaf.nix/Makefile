# Makefile for managing Nix flake operations

NIX_FLAKE_DIR := ../..
NIX_BUILD_ARGS := --extra-experimental-features 'nix-command flakes'
NIX_EVAL_ARGS := --raw --extra-experimental-features 'nix-command flakes'
NIX_EVAL_JSON_ARGS := --json --extra-experimental-features 'nix-command flakes'

# Default system for evaluation (can be overridden)
SYSTEM ?= aarch64-linux

.PHONY: all build-w3c-repos-nar eval-cwm-overall-status eval-cwm-validation-results eval-lib-attributes hello clean \
        extract-w3c-repos-nar inspect-w3c-repos-nar

all: build-w3c-repos-nar eval-cwm-overall-status

build-w3c-repos-nar:
	@echo "Building w3cReposNar..."
	nix build $(NIX_BUILD_ARGS) $(NIX_FLAKE_DIR)#$(SYSTEM).lib.w3cReposNar

eval-cwm-overall-status:
	@echo "Evaluating CWM overallStatus..."
	nix eval $(NIX_EVAL_ARGS) $(NIX_FLAKE_DIR)#$(SYSTEM).lib.cwm.overallStatus

eval-cwm-validation-results:
	@echo "Evaluating CWM validationResults..."
	nix eval $(NIX_EVAL_ARGS) $(NIX_FLAKE_DIR)#$(SYSTEM).lib.cwm.validationResults

eval-lib-attributes:
	@echo "Evaluating lib attributes for $(SYSTEM)..."
	nix eval $(NIX_EVAL_JSON_ARGS) $(NIX_FLAKE_DIR)#$(SYSTEM).lib | jq

hello:
	@echo "Hello from Nix flake!"

# New targets for breaking up and inspecting w3cReposNar
extract-w3c-repos-nar: build-w3c-repos-nar
	@echo "Extracting w3cReposNar..."
	nix-store --restore $(shell readlink result) > w3c-repos-nar-extracted
	@echo "Extracted NAR to w3c-repos-nar-extracted"

inspect-w3c-repos-nar: extract-w3c-repos-nar
	@echo "Inspecting extracted w3cReposNar..."
	ls -l w3c-repos-nar-extracted
	cat w3c-repos-nar-extracted/repos.json | jq .

clean:
	@echo "Cleaning up Nix build results..."
	rm -f result
	rm -rf w3c-repos-nar-extracted
	nix-collect-garbage --delete-old
