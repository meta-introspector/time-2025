NIX_FLAKE_PATH := ../..
OBSERVE_FLAKE_PATH := .

.PHONY: test
test:
	@echo "Building initialState..."
	@nix build $(NIX_FLAKE_PATH)#initialState > /dev/null
	@echo "Evaluating observe flake with initialState..."
	@nix eval --raw $(OBSERVE_FLAKE_PATH)#default --apply 'x: x { currentState = "$(readlink result)"; }'
	@echo "Observe flake test complete."
