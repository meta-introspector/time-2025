# How to Update `npmDepsHash` in Nix Expressions

When working with Nix and `buildNpmPackage` or `buildNpmDeps`, you might encounter a `hash mismatch` error related to `npmDepsHash`. This hash is used by Nix to ensure the reproducibility of your `node_modules` dependencies. If the dependencies change (e.g., due to new versions, different lock files, or changes in the source), the hash will no longer match, and the build will fail.

This document explains how to update the `npmDepsHash` when such a mismatch occurs.

## Understanding the Error

A typical `hash mismatch` error will look something like this:

```
error: hash mismatch in fixed-output derivation '/nix/store/...-npm-deps.drv':
         specified: sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=
            got:    sha256-uX9M3xnsMnjwRqjl/sDWb+A8Km6f5du91SoDRH4zY24=
```

*   `specified`: This is the hash that Nix *expected* to see.
*   `got`: This is the hash that Nix *actually* calculated from the `node_modules` it tried to build or fetch.

To resolve the error, you need to replace the `specified` hash in your Nix expression with the `got` hash.

## Steps to Update `npmDepsHash`

1.  **Identify the `hash mismatch` error:** Run your Nix build or shell command (e.g., `nix-shell`, `nix build`, `nix run`). Look for the `hash mismatch` error message in the output.

2.  **Extract the "got" hash:** From the error message, copy the `sha256-...` string that appears after `got:`. This is the new, correct hash you need to use.

    *Example:* If the error shows `got:    sha256-uX9M3xnsMnjwRqjl/sDWb+A8Km6f5du91SoDRH4zY24=`, then `sha256-uX9M3xnsMnjwRqjl/sDWb+A8Km6f5du91SoDRH4zY24=` is your new hash.

3.  **Locate the `npmDepsHash` in your Nix expression:** Open the `flake.nix` or `default.nix` file that contains the `buildNpmPackage` or `buildNpmDeps` call. Find the `npmDepsHash` attribute.

    *Example (in `default.nix`):*
    ```nix
geminiCliPackage = nixpkgs.buildNpmPackage {
      # ... other attributes ...
      npmDepsHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # This is the old hash
      # ... other attributes ...
    };
    ```

4.  **Replace the old hash with the new hash:** Update the value of `npmDepsHash` with the "got" hash you extracted in step 2.

    *Example (after update):*
    ```nix
geminiCliPackage = nixpkgs.buildNpmPackage {
      # ... other attributes ...
      npmDepsHash = "sha256-uX9M3xnsMnjwRqjl/sDWb+A8Km6f5du91SoDRH4zY24="; # This is the new hash
      # ... other attributes ...
    };
    ```

5.  **Re-run your Nix command:** Execute your Nix build or shell command again. If the hash was the only issue, the build should now proceed further or complete successfully.

## Common Pitfalls

*   **Incorrectly copying the hash:** Ensure you copy the entire `sha256-...` string accurately.
*   **Multiple `npmDepsHash` instances:** If your Nix expression has multiple `buildNpmPackage` or `buildNpmDeps` calls, make sure you're updating the correct one.
*   **Underlying dependency changes:** If the `node_modules` content changes frequently, you might need to update this hash often. Consider if there's a more stable way to manage your dependencies or if the `src` input itself needs to be updated.
