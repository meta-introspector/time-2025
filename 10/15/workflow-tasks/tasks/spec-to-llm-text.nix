{ pkgs, lib, builtins }:
specFlakePath: # This task takes the path to a spec flake
let
  # Import the spec flake to get its attributes
  spec = import specFlakePath { inherit lib pkgs; };
in
pkgs.runCommand "spec-to-llm-text" {
  inherit specFlakePath;
  specName = spec.name;
  specDescription = spec.description;
  specTaskType = spec.taskType;
  specInputs = builtins.toJSON spec.inputs; # Convert inputs to JSON string
  specOutputs = builtins.toJSON spec.outputs; # Convert outputs to JSON string
} ''
  set -euo pipefail

  cat > "$out" <<EOF
# Task Specification: $specName

## Description
$specDescription

## Task Type
$specTaskType

## Inputs
```json
$specInputs
```

## Outputs
```json
$specOutputs
```

---
Please use the above specification to generate a detailed plan or code for implementing this task.
EOF
''
