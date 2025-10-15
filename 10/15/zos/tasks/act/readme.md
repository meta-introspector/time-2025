# ZOS Act Task

This flake defines the Act task for the Zero-One-System (ZOS). It executes the planned actions and produces new tasks/state.

## Testing

To test the `act` flake with dummy inputs:

1. Evaluate the `act` flake's default output with a dummy `actionPlan` and `dwimFlake`:
   ```bash
   nix eval --raw .#default --apply 'x: x { actionPlan = "dummy-action-plan"; dwimFlake = { lib = { aarch64-linux = { dwim = "/nix/store/dummy-dwim"; }; }; }; }; }'
   ```
   This command will evaluate the `act` function and return the path to the generated new tasks and state.
