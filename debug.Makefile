NIX_FLAKE_ROOT := $(shell pwd)
NIX_FLAKE_09 := $(NIX_FLAKE_ROOT)/09
SYSTEM := aarch64-linux

.PHONY: all debug-streamofrandom09-outputs debug-streamofrandom09-outputs-system

all: debug-streamofrandom09-outputs debug-streamofrandom09-outputs-system

debug-streamofrandom09-outputs:
	@echo "--- Evaluating streamofrandom09Outputs (full) ---"
	nix eval --json $(NIX_FLAKE_09) --apply 'x: x.outputs { nixpkgs = x.inputs.nixpkgs; flake-utils = x.inputs.flake-utils; self = x; search-results = x.inputs.search-results; }' > streamofrandom09Outputs_full.json
	@echo "Output saved to streamofrandom09Outputs_full.json"

debug-streamofrandom09-outputs-system:
	@echo "--- Evaluating streamofrandom09Outputs.${SYSTEM} ---"
	nix eval --json $(NIX_FLAKE_09) --apply 'x: x.outputs { nixpkgs = x.inputs.nixpkgs; flake-utils = x.inputs.flake-utils; self = x; search-results = x.inputs.search-results; }.${SYSTEM}' > streamofrandom09Outputs_system.json
	@echo "Output saved to streamofrandom09Outputs_system.json"
