# Lock to Flake Input Converter

This flake (`10/15/locktoinput/`) is designed to dynamically convert collected `flake.lock` data into a set of usable Nix flake inputs. This is a crucial step in managing external dependencies and ensuring reproducibility without directly mirroring every single upstream repository.

## Purpose

The primary goal is to:

1.  **Collect Lock Data**: Utilize the `10/12/audit-flakes/001_collect_locks` flake to gather information about all `flake.lock` files within a project.
2.  **Parse Lock Information**: Extract relevant details (like owner, repository, reference, and directory) from the aggregated `lock-file-info.json`.
3.  **Generate Dynamic Flake Inputs**: Create a set of Nix flake inputs based on the parsed lock data. These inputs can then be used by other flakes or derivations.
4.  **Reduce GitHub Overload**: By processing lock files and potentially mirroring or localizing inputs, we aim to reduce direct reliance on GitHub for every build, especially for frequently accessed dependencies.

## How it Works

This flake takes the `001_collect_locks` flake as an input. It then accesses the `all-lock-file-summaries.json` output from `001_collect_locks`, which contains a list of `lock-file-info.json` entries. Each entry is parsed, and a corresponding flake input is generated. The `githubWrapper` utility is used to construct the appropriate `github:` URLs for these inputs.

## Usage

To check the flake:

```bash
nix flake check . --extra-experimental-features "nix-command flakes impure-derivations ca-derivations"
```

To run the default application (which prints the generated flake inputs):

```bash
nix run .#default --extra-experimental-features "nix-command flakes impure-derivations ca-derivations"
```

To build the default package (which contains a text file with the calculated URL):

```bash
nix build .#default --extra-experimental-features "nix-command flakes impure-derivations ca-derivations"
```

## Outputs

*   `lib.generatedInputs`: An attribute set where each key is a generated input name (e.g., `input-0`, `input-1`) and the value is an attribute set containing the `url` for that input.
*   `apps.<system>.default`: A simple application that prints the URLs of the generated flake inputs.
*   `packages.<system>.default`: A derivation that outputs a text file containing the URLs of the generated flake inputs.