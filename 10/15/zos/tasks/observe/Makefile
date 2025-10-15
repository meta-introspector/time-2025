NIX_FLAKE_ROOT := ../../..
OBSERVE_FLAKE_PATH := .

.PHONY: test
test:
	@echo "Evaluating observe flake with dummy inputs..."
	@nix eval --raw $(OBSERVE_FLAKE_PATH)#default --apply 'x: x { currentState = "{ \"actState\": \"dummy-act-state\", \"decidePlan\": \"dummy-decide-plan\" }"; }' --no-write-lock-file
	@echo "Observe flake test complete."