# Test Scripts

This directory contains various test scripts used for development and debugging.

## `temp_eval.nix`

This Nix expression is used to evaluate and inspect the attributes of the `naersk.lib.${system}` attribute set from the `flake_auditor` flake. It helps in understanding the available functions and packages provided by `naersk`.

### Usage

To evaluate this script and get a list of attributes, navigate to this directory and run:

```bash
nix eval --json -f temp_eval.nix
```

This will output a JSON array of attribute names found in `naersk.lib.aarch64-linux`.
