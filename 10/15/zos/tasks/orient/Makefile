NIX_FLAKE_ROOT := github:meta-introspector/time-2025?ref=feature/aimyc-003-cultivation
ZOS_FLAKE_REF := $(NIX_FLAKE_ROOT)&dir=10/15/zos
OBSERVE_FLAKE_PATH := $(ZOS_FLAKE_REF)/tasks/observe
ORIENT_FLAKE_PATH := .

.PHONY: test
test:
	@echo "Building initialState..."
	@nix build $(ZOS_FLAKE_REF)#initialState > /dev/null
	@echo "Evaluating observe flake with initialState..."
#	@OBSERVATION_REPORT=$$(nix eval --raw $(OBSERVE_FLAKE_PATH)#default --apply "x: x { currentState = \"$$(readlink result)\"; }" --no-write-lock-file)
	#@echo "Observation Report: $$OBSERVATION_REPORT"
	@echo "Evaluating orient flake with observationReport and dummy llmGeneratorFlake..."
	@bash ${./test-orient-flake.sh}
	@echo "Orient flake test complete."
