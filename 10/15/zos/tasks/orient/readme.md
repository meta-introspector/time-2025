# ZOS Orient Task

This flake defines the Orient task for the Zero-One-System (ZOS). It interprets observations and identifies next steps.

## Testing

To test the `orient` flake with dummy inputs:

1. Build `zos#initialState` to get a `currentState` path:
   ```bash
   nix build ../../..#initialState
   ```
   This will create a `result` symlink pointing to the `currentState` derivation.

2. Evaluate the `observe` flake's default output with the `currentState`:
   ```bash
   nix eval --raw ../../observe#default --apply 'x: x { currentState = "$(readlink result)"; }'
   ```
   This will create a `result` symlink pointing to the `observationReport` derivation.

3. Evaluate the `orient` flake's default output with the `observationReport` and a dummy `llmGeneratorFlake`:
   ```bash
   nix eval --raw .#default --apply 'x: x { observationReport = "$(readlink result)"; llmGeneratorFlake = { lib = { aarch64-linux = { llmPipeline = { llmOrchestratorScript = "/nix/store/dummy-llm-orchestrator-script"; }; }; }; }; }; }'
   ```
   This command will evaluate the `orient` function and return the path to the generated orientation decision.
