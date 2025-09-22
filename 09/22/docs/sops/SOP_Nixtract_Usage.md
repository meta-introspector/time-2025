# SOP: Nixtract Usage and Graph Generation

## 1. Purpose

This Standard Operating Procedure (SOP) details the usage of the `nixtract` CLI tool for extracting and analyzing dependency graphs from Nix flakes within the project. It aims to provide clear instructions for generating graph data, understanding its format, and troubleshooting common issues.

## 2. Scope

This SOP applies to all developers and contributors working with Nix flakes in the project who need to understand or visualize Nix package dependencies.

## 3. Prerequisites

*   Nix installed on your system (version 2.4 or later recommended).
*   `nix-command` and `flakes` experimental features enabled in your `nix.conf`.
*   Access to the `nixtract` tool, typically via `nix run nixpkgs#nixtract` or a local installation.

## 4. Procedure: Generating a Nix Dependency Graph

The `nixtract` tool can be used to generate a JSONL (JSON Lines) output, where each line represents a derivation or a dependency in the Nix build graph.

### 4.1. Basic Usage

To generate the dependency graph for the current project's flake and output it to a file named `derivations.jsonl`:

```bash
nix run nixpkgs#nixtract -- --target-flake-ref "$(pwd)"/# --pretty > derivations.jsonl
```

*   `nix run nixpkgs#nixtract`: Executes the `nixtract` tool from `nixpkgs`.
*   `--target-flake-ref "$(pwd)"/#`: Specifies the target flake. `$(pwd)` resolves to the absolute path of the current working directory, and `#` refers to the default flake output.
*   `--pretty`: Formats the JSONL output for better readability.
*   `> derivations.jsonl`: Redirects the output to a file named `derivations.jsonl`.

### 4.2. Targeting Specific Flakes or Attributes

*   **For a specific flake URI (e.g., an external flake):**
    ```bash
    nix run nixpkgs#nixtract -- --target-flake-ref 'github:NixOS/nixpkgs#hello' --pretty > nixpkgs_hello_derivations.jsonl
    ```
*   **For a specific attribute path within a flake:**
    ```bash
    nix run nixpkgs#nixtract -- --target-flake-ref "$(pwd)"/# --target-attribute-path 'packages.x86_64-linux.myPackage' --pretty > mypackage_derivations.jsonl
    ```

### 4.3. Filtering and Optimization

For very large flakes, generating the full graph can be time-consuming. Consider these options:

*   **`--target-attribute-path <ATTRIBUTE_PATH>`**: Extract only the graph for a specific attribute.
*   **`--target-system <SYSTEM>`**: Specify a target system (e.g., `x86_64-linux`) if you only need the graph for a particular architecture.
*   **`--runtime-only`**: (If available in your `nixtract` version) Only consider runtime dependencies.

## 5. Reviewing the Output (`derivations.jsonl`)

The `derivations.jsonl` file contains a series of JSON objects, one per line. Each object describes a derivation, including its name, version, license, and dependencies.

*   **View first few lines:**
    ```bash
    head derivations.jsonl
    ```
*   **Pretty-print a single JSON object (requires `jq`):**
    ```bash
    head -n 1 derivations.jsonl | jq .
    ```

## 6. Troubleshooting

*   **"flake reference '.' is not an absolute path" error:** Ensure `--target-flake-ref` is provided with an absolute path or a valid flake URI.
*   **Long execution time/large output:** Use filtering options (`--target-attribute-path`, `--target-system`) to narrow down the scope of the graph.
*   **`nix run` errors:** Verify your Nix installation and network connectivity.

## 7. Related Documentation

*   [CRQ-016: Submodule Nixification and Flake Refactoring](docs/crqs/CRQ_016_Submodule_Nixification.md)
*   [Memo: Use Shellcheck Always After Changes](docs/memos/Shellcheck_Always_After_Changes.md)
*   [CRQ-002: Nixtract Integration and Quality](docs/crqs/CRQ_002_Nixtract_Integration_and_Quality.md)
*   [SOP: Nix Graph Analysis](docs/sops/SOP_Nix_Graph_Analysis.md)
*   [nixtract GitHub Repository](https://github.com/tweag/nixtract)
