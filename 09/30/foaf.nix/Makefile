# Makefile for managing Nix flake operations

NIX_FLAKE_DIR := ../..
NIX_BUILD_ARGS := --extra-experimental-features 'nix-command flakes'
NIX_EVAL_ARGS := --raw --extra-experimental-features 'nix-command flakes'

# Default system for evaluation (can be overridden)
SYSTEM ?= aarch64-linux

.PHONY: all build-w3c-repos-nar eval-cwm-overall-status eval-cwm-validation-results clean

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

clean:
	@echo "Cleaning up Nix build results..."
	rm -f result
	nix-collect-garbage --delete-old
