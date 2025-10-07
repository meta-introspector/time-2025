NIX_FLAKE_ROOT := $(shell pwd)
NIX_FLAKE_09 := $(NIX_FLAKE_ROOT)/09
SYSTEM := aarch64-linux

.PHONY: all debug-system-outputs

all: debug-system-outputs

debug-system-outputs:
	@echo "--- Evaluating ./09 flake outputs for ${SYSTEM} ---"
	nix eval --json $(NIX_FLAKE_09) --raw --expr 'let flake = import $(NIX_FLAKE_09); in flake.outputs { nixpkgs = flake.inputs.nixpkgs; flake-utils = flake.inputs.flake-utils; self = flake; search-results = flake.inputs.search-results; }.${SYSTEM}' > streamofrandom09Outputs_system.json
	@echo "Output saved to streamofrandom09Outputs_system.json"
