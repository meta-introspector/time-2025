# Mycology Flake - Monster Group Prime Lattice

## Description

This Nix flake defines the prime factorization of the Monster Group's order and related prime groupings. It provides a way to expose this data for other Nix expressions or for direct evaluation, and also generates a JSON file containing this data.

## Inputs

-   `nixpkgs`: Standard Nixpkgs input, using `github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify` for project consistency.

## Outputs

### `packages.${system}.default`

This output is a Nix derivation (package) that, when built, produces a JSON file named `monster-lattice.json`. This file contains the prime factorization of the Monster Group's order and the defined prime groupings.

-   **Output File:** `monster-lattice.json`
-   **Content Structure:**
    ```json
    {
      "groupings": [[0, 1, 2, 3], [5, 7, 11, 13], [17, 19, 23, 31]],
      "orderFactorization": {
        "2": 46,
        "3": 20,
        "5": 9,
        "7": 6,
        "11": 2,
        "13": 3,
        "17": 1,
        "19": 1,
        "23": 1,
        "29": 1,
        "31": 1,
        "41": 1,
        "47": 1,
        "59": 1,
        "71": 1
      }
    }
    ```

### `lib.monsterGroupData`

This output exposes the raw attribute set containing the Monster Group's order factorization and prime groupings. It is suitable for direct consumption by other flakes or Nix expressions that need to access this data programmatically.

-   **Type:** Nix attribute set
-   **Structure:**
    ```nix
    {
      orderFactorization = {
        "2" = 46;
        "3" = 20;
        "5" = 9;
        "7" = 6;
        "11" = 2;
        "13" = 3;
        "17" = 1;
        "19" = 1;
        "23" = 1;
        "29" = 1;
        "31" = 1;
        "41" = 1;
        "47" = 1;
        "59" = 1;
        "71" = 1;
      };
      groupings = [
        [ 0 1 2 3 ]
        [ 5 7 11 13 ]
        [ 17 19 23 31 ]
      ];
    }
    ```

## Usage

To "run" this flake and retrieve the Monster Group data, follow these steps:

1.  **Build the default package (JSON output):**
    This command builds the `monster-lattice.json` file in the Nix store.

    ```bash
    nix build --no-link "/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/10/14#default"
    ```

2.  **View the content of the generated JSON file:**
    After building, you can view the content of the `monster-lattice.json` file directly from the Nix store. Replace `<path_to_json_in_nix_store>` with the actual path obtained from the build output (e.g., `/nix/store/w82v57fqrdryfv3qfqhawzrm0kyz0jwz-monster-lattice.json`).

    ```bash
    nix cat-store <path_to_json_in_nix_store>
    ```

    Example:
    ```bash
    nix cat-store /nix/store/w82v57fqrdryfv3qfqhawzrm0kyz0jwz-monster-lattice.json
    ```

    This will output the JSON content:
    ```json
    {"groupings":[[0,1,2,3],[5,7,11,13],[17,19,23,31]],"orderFactorization":{"11":2,"13":3,"17":1,"19":1,"2":46,"23":1,"29":1,"3":20,"31":1,"41":1,"47":1,"5":9,"59":1,"7":6,"71":1}}
    ```