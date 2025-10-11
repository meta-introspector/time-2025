# 6. Refactoring Example: `export-nar.nix`

This section demonstrates the refactoring of `10/10/export-nar.nix` to leverage the `nar-locator` flake for standardized NAR creation. This flake is responsible for generating a NAR containing a list of Nix files.

## Before Refactoring

Originally, `export-nar.nix` directly used `nix-store --dump` to create its output NAR:

```nix
{ pkgs ? import <nixpkgs> {} }:

let
  nix2-src = pkgs.lib.sources.cleanSource ./nix2;
  get-nix-file-list = nix2-src + "/get-nix-file-list.nix";
in
pkgs.runCommand "nix-file-list-nar" {} ''
  # Generate the JSON file
  ${pkgs.nix}/bin/nix eval --raw -f ${get-nix-file-list} > nix-file-list.json

  # Add the JSON file to the store
  store_path=$(${pkgs.nix}/bin/nix-store --add nix-file-list.json)

  # Dump the store path to a NAR file
  ${pkgs.nix}/bin/nix-store --dump $store_path > $out
''
```

This direct approach, while functional, did not conform to the project's new standards for NAR naming and organization.

## After Refactoring

To integrate the `nar-locator` flake, `export-nar.nix` was modified as follows:

1.  **Added `narLocatorFlake` Input:**
    The `nar-locator` flake was added as an argument to the `export-nar.nix` file:

    ```nix
    { pkgs ? import <nixpkgs> {}, narLocatorFlake }:

    # ... (rest of the file)
    ```

2.  **Replaced `nix-store --dump` Call with `narLocatorFlake.lib.locateAndDumpNar`:**

    The entire `pkgs.runCommand` block that previously handled the NAR creation was replaced with a call to `narLocatorFlake.lib.locateAndDumpNar`:

    ```nix
    # ... (let block)

narLocatorFlake.lib.locateAndDumpNar {
  storePath = pkgs.runCommand "nix-file-list-store-path" {
    buildInputs = [ pkgs.nix ];
    nix2-src = pkgs.lib.sources.cleanSource ./nix2;
    get-nix-file-list = nix2-src + "/get-nix-file-list.nix";
  } ''
    # Generate the JSON file
    ${pkgs.nix}/bin/nix eval --raw -f ${get-nix-file-list} > nix-file-list.json

    # Add the JSON file to the store and output its path
    echo "$(nix-store --add nix-file-list.json)" > $out
  '';
  originalFilePath = "nix-file-list.json";
}
    ```

### Explanation of Changes:

*   The `export-nar.nix` now takes `narLocatorFlake` as an argument, allowing it to access the `locateAndDumpNar` function.
*   The `storePath` argument to `locateAndDumpNar` is now a `pkgs.runCommand` that generates the `nix-file-list.json` and adds it to the Nix store, outputting the resulting store path. This ensures that the content to be NAR'd is properly prepared as a store path.
*   The `originalFilePath` is set to `nix-file-list.json`, which the `nar-locator` uses to derive the canonical NAR filename and its placement within the structured output.

This refactoring ensures that the NAR containing the Nix file list is created and organized according to the project's new NAR management standards, enhancing consistency and traceability.
