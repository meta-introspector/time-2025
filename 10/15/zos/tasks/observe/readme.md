# ZOS Observe Task

This flake defines the Observe task for the Zero-One-System (ZOS). It analyzes the current system state and generates an observation report.

## Testing

To test the `observe` flake with a dummy `currentState` (obtained by building `zos#initialState`):

1. Build `zos#initialState` to get a `currentState` path:
   ```bash
   nix build 10/15/zos#initialState
   ```
   This will create a `result` symlink pointing to the `currentState` derivation.

2. Evaluate the `observe` flake's default output with the `currentState`:
   ```bash
   nix eval --raw 10/15/zos/tasks/observe#default --apply 'x: x { currentState = "$(readlink result)"; }'
   ```
   This command will evaluate the `observe` function and return the path to the generated observation report.
