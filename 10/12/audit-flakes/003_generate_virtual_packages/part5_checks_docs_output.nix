checks.virtualPackages = pkgs.runCommand "virtual-packages-check" {
inherit virtualPackages;
} "echo \"${builtins.toJSON (lib.mapAttrs (name: value: value) virtualPackages)}\" > $out";

docs.usage = pkgs.writeText "usage.md" ''
# Flake: 003_generate_virtual_packages

## Purpose

This flake is the third step in the flake audit process. It takes the extracted data from `002_extract_data` and generates a "virtual package" for each item, associating it with a unique (placeholder) emoji string.

## Inputs

*   `nixpkgs`: Standard Nixpkgs input.
*   `flake-utils`: Utility functions for Nix flakes.
*   `extractedData`: The output from the `002_extract_data` flake, which is a derivation containing a JSON file with all extracted data.

## Outputs

*   `packages.default`: A derivation containing a JSON file (`all-virtual-packages.json`) which is a single JSON array containing all the data from the generated virtual packages.
*   `packages.<emoji-string>`: Individual virtual packages, each containing a JSON file with the data for a specific extracted item.
*   `checks.virtualPackages`: A check that outputs the JSON representation of all virtual packages, useful for debugging and verification.

## Usage

To build the default package (the aggregated JSON file of all virtual packages):

```bash
nix build .#default
```

To build a specific virtual package (e.g., for the first item, which currently has a placeholder emoji string):

```bash
nix build .#packages.fixme
cat ./result
```

To inspect all virtual packages (for debugging):

```bash
nix build .#checks.virtualPackages
cat ./result
```

This flake is designed to be chained with subsequent flakes in the audit process.
'';
}
);
}
