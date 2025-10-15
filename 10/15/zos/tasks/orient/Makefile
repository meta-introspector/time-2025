NIX_FLAKE_ROOT := ../../..
OBSERVE_FLAKE_PATH := $(NIX_FLAKE_ROOT)/tasks/observe
ORIENT_FLAKE_PATH := .

.PHONY: test
test:
	@echo "Building initialState..."
	@nix build $(NIX_FLAKE_ROOT)#initialState > /dev/null
	@echo "Evaluating observe flake with initialState..."
	@OBSERVATION_REPORT=$$(nix eval --raw $(OBSERVE_FLAKE_PATH)#default --apply 'x: x { currentState = "$(readlink result)"; }')
	@echo "Observation Report: $$OBSERVATION_REPORT"
	@echo "Evaluating orient flake with observationReport and dummy llmGeneratorFlake..."
	@nix eval --raw $(ORIENT_FLAKE_PATH)#default --apply 'x: x { observationReport = "$$OBSERVATION_REPORT"; llmGeneratorFlake = { lib = { aarch64-linux = { llmPipeline = { llmOrchestratorScript = "/nix/store/dummy-llm-orchestrator-script"; }; }; }; }; }; }'
	@echo "Orient flake test complete."
