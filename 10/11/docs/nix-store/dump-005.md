# 5. Refactoring Example: `search-results/flake.nix`

This section details the refactoring of `09/flakes/search-results/flake.nix` to utilize the `nar-locator` flake for standardized NAR creation. This flake generates various NARs related to GitHub search results, repository lists, and Solana block data.

## Before Refactoring

Previously, `search-results/flake.nix` contained multiple direct calls to `nix-store --dump` within its derivations, similar to the following pattern:

```nix
# Example from mkSearchNar
            builder = pkgs.writeShellScript "search-builder" ''
              # ... (logic to prepare TEMP_DIR)
              nix-store --dump "$TEMP_DIR" > "$out"/${(pkgs.lib.replaceStrings [" "] ["-"] keyword)}.nar
              # ...
            '';

# Example from mkRepoListNar
            builder = pkgs.writeShellScript "repo-list-builder" ''
              # ... (logic to prepare TEMP_DIR)
              nix-store --dump "$TEMP_DIR" > "$out"/repos-${ownerName}.nar
              # ...
            '';

# Example from solanaBlockNar
          builder = pkgs.writeShellScript "solana-block-builder" ''
            # ... (logic to prepare TEMP_DIR)
            nix-store --dump "$TEMP_DIR" > "$out"/solana-block-number.nar
            # ...
          '';
```

These direct calls resulted in custom output paths and lacked the centralized management benefits of the `nar-locator`.

## After Refactoring

To align with the new NAR management policy, `search-results/flake.nix` was updated as follows:

1.  **Added `narLocatorFlake` Input:**
    The `nar-locator` flake was added as an input:

    ```nix
    inputs = {
      # ... (existing inputs)
      narLocatorFlake = {
        url = "path:../../../../10/11/nar-locator"; # Relative path to the nar-locator flake
        inputs.nixpkgs.follows = "nixpkgs";
      };
    };

    outputs = { self, nixpkgs, flake-utils, pickUpNix2, narLocatorFlake, ... }:
      # ... (rest of the outputs function)
    ```

2.  **Replaced `nix-store --dump` Calls with `narLocatorFlake.lib.locateAndDumpNar`:**

    *   **`mkSearchNar` Refactoring:**
        The `mkSearchNar` function now wraps its content in a `pkgs.runCommand` to produce a store path, which is then passed to `locateAndDumpNar`.

        ```nix
        mkSearchNar = keyword:
          narLocatorFlake.lib.locateAndDumpNar {
            storePath = pkgs.runCommand "temp-search-dir" {
              nativeBuildInputs = with pkgs;
                [ gh # GitHub CLI
                  jq # JSON processor
                ];
              TEMP_DIR = "$(mktemp -d)";
            }
            ''
              set -euo pipefail

              echo "Performing GitHub search for keyword: \"${keyword}\""
              # ... (original search logic)

              cp -r "$TEMP_DIR"/* $out
            '';
            originalFilePath = "github-search-${(pkgs.lib.replaceStrings [" "] ["-"] keyword)}";
          };
        ```
        Here, `storePath` is the temporary directory containing the search results, and `originalFilePath` is derived from the `keyword` for canonical naming.

    *   **`mkRepoListNar` Refactoring:**
        Similarly, `mkRepoListNar` now uses `locateAndDumpNar`.

        ```nix
        mkRepoListNar = ownerName:
          narLocatorFlake.lib.locateAndDumpNar {
            storePath = pkgs.runCommand "temp-repo-list-dir" {
              buildInputs = with pkgs; [
                gh # GitHub CLI
                jq # JSON processor
              ];
              TEMP_DIR = "$(mktemp -d)";
            }
            ''
              set -euo pipefail

              echo "Listing GitHub repositories for owner: ${ownerName}"
              # ... (original repo list logic)

              cp -r "$TEMP_DIR"/* $out
            '';
            originalFilePath = "repos-${ownerName}";
          };
        ```
        `storePath` is the temporary directory with repository data, and `originalFilePath` is `repos-${ownerName}`.

    *   **`solanaBlockNar` Refactoring:**
        The `solanaBlockNar` derivation also adopts `locateAndDumpNar`.

        ```nix
        solanaBlockNar = narLocatorFlake.lib.locateAndDumpNar {
          storePath = pkgs.runCommand "temp-solana-block-dir" {
            buildInputs = with pkgs; [
              curl # For making HTTP requests to Solana RPC
              jq   # For parsing JSON response
            ];
            TEMP_DIR = "$(mktemp -d)";
          }
          ''
            set -euo pipefail

            echo "Fetching latest Solana block number..."
            # ... (original Solana block fetching logic)

            cp -r "$TEMP_DIR"/* $out
          '';
          originalFilePath = "solana-block-number";
        };
        ```
        `storePath` is the temporary directory holding the block number, and `originalFilePath` is `solana-block-number`.

This comprehensive refactoring ensures that all NARs generated within `search-results/flake.nix` are now consistently named and organized according to the `nar-locator`'s rules, improving the overall manageability of these critical data artifacts.
