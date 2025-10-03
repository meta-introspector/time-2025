NIX_FLAKE_ROOT := $(shell pwd)
NIX_FLAKE_09 := $(NIX_FLAKE_ROOT)/09

.PHONY: all debug-full-outputs

all: debug-full-outputs

debug-full-outputs:
	@echo "--- Evaluating ./09 flake outputs (full) ---"
	nix eval --json $(NIX_FLAKE_09) --raw --expr 'let flake = import $(NIX_FLAKE_09); in flake.outputs { nixpkgs = flake.inputs.nixpkgs; flake-utils = flake.inputs.flake-utils; self = flake; search-results = flake.inputs.search-results; }' > streamofrandom09Outputs_full.json
	@echo "Output saved to streamofrandom09Outputs_full.json"
