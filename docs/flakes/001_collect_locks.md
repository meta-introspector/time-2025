# 001_collect_locks Flake

## Description

This Nix flake is the first step in the flake audit process. Its primary purpose is to recursively find and collect information about all `flake.lock` files within a given project directory. For each `flake.lock` file found, it generates a structured JSON report (`lock-file-info.json`) that includes metadata about the `flake.nix` and `flake.lock` files, as well as a bag-of-words representation of the `flake.nix` content.

## Inputs

-   `nixpkgs`: Standard Nixpkgs input.
-   `flake-utils`: Utility functions for Nix flakes.
-   `project`: The root path of the project to be audited. This input should be treated as a path, not a flake.
-   `bagOfWordsGenerator`: A reference to the `bag-of-words-generator` flake, used to generate bag-of-words reports for `flake.nix` files.

## Outputs

-   `packages.*`: Individual derivations, each containing a `lock-file-info.json` for a specific `flake.lock` file found in the project. The attribute names are `lock-file-0`, `lock-file-1`, etc.
-   `packages.default`: An aggregation of all `lock-file-info.json` outputs into a single `all-lock-file-summaries.json` file.
-   `checks.allLockFilePackageNames`: A check that outputs a JSON array of the attribute names of the `packages.*` derivations (e.g., `["lock-file-0", "lock-file-1"]`), useful for debugging and verification.
-   `test_flake_sh`: A path to the `test_flake_sh.sh` script, used for testing the `flake.sh` script.

## `flake.sh` Script

This shell script is executed by the `runCommand` for each `lock-file-N` derivation. It orchestrates the collection of information and the generation of the `lock-file-info.json`.

### Expectations (Environment Variables)

The `flake.sh` script expects the following environment variables to be set by the Nix build environment:

-   `out`: The output path for the derivation.
-   `NIX_FILE_PATH`: The absolute path to the `flake.nix` file associated with the current `flake.lock`.
-   `lockFile`: The absolute path to the `flake.lock` file being processed.
-   `BAG_OF_WORDS_GENERATOR_PATH`: The absolute path to the fetched `bag-of-words-generator` flake.

### Internal Logic

1.  **Get System:** Dynamically determines the current system (e.g., `aarch64-linux`) using `nix eval 'builtins.currentSystem'`.
2.  **Generate Bag-of-Words:** Calls the `generateBagOfWords` function from the `bagOfWordsGenerator` flake using `nix build`. It passes `NIX_FILE_PATH` as the `flakePath` argument to this function. The resulting `report.json` is captured.
3.  **Generate `lock-file-info.json`:** Uses `jq` to combine `NIX_FILE_PATH`, `lockFile`, and the generated bag-of-words into a structured JSON object, which is then written to `$out/lock-file-info.json`.

## `lock-file-info.json` Structure

This JSON file contains detailed information about a single `flake.lock` file and its corresponding `flake.nix`.

```json
{
  "nixFilePath": "/absolute/path/to/flake.nix",
  "lockFilePath": "/absolute/path/to/flake.lock",
  "bagOfWords": {
    "word1": count1,
    "word2": count2,
    ...
  }
}
```

## Usage Example (within another Flake)

To use the output of this flake in another flake, you would typically access the `packages.default` attribute to get the aggregated summary, or individual `packages.lock-file-N` attributes for specific lock file information.

```nix
let
  collectLocks = inputs.collect_locks_flake; # Assuming collect_locks_flake is an input
  allSummaries = collectLocks.packages.default; # Path to all-lock-file-summaries.json
  firstLockFileInfo = collectLocks.packages.lock-file-0; # Path to lock-file-info.json for the first lock file
in
  # ... use allSummaries or firstLockFileInfo ...
```

## Testing

To verify the functionality of this flake, you can run its associated test flake. The test flake executes the `flake.sh` script in a simulated Nix build environment and checks its output.

```bash
nix flake check 10/12/audit-flakes/001_collect_locks/test_flake.nix
```

If the check passes, it means the `flake.sh` script executed successfully and produced the expected `lock-file-info.json` output. The output of the test will be printed to the console during the check process.

## Documentation Output

To view the documentation for this flake, you can build its `docs.usage` output:

```bash
nix build 10/12/audit-flakes/001_collect_locks/.#docs.usage
cat ./result
```
