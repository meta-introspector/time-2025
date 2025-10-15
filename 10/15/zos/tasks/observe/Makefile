NIX_FLAKE_PATH := 10/15/zos
OBSERVE_FLAKE_PATH := $(NIX_FLAKE_PATH)/tasks/observe

.PHONY: test
test:
	@echo "Building initialState..."
	@nix build $(NIX_FLAKE_PATH)#initialState > /dev/null
	@echo "Evaluating observe flake with initialState..."
	@nix eval --raw $(OBSERVE_FLAKE_PATH)#default --apply 'x: x { currentState = "$(readlink result)"; }'
	@echo "Observe flake test complete."
