# CRQ-809: Auditable N-Gram Analysis as a Nix Derivation

- **Status:** Proposed
- **Requester:** User
- **Date:** 2025-09-23
- **Related CRQs:** CRQ-808 (Similarity Search using N-Gram Index)

## 1. Problem

Following the creation of the initial n-gram indexing script (CRQ-808), the process remains manual. The `ngram_index.json` file is a static artifact, and the analysis is performed by manually running a script.

This approach lacks the reproducibility and auditability that is central to the project's Nix-based philosophy. There is no "proof" connecting the analysis results back to the specific versions of the source files used to generate them.

## 2. Proposed Solution

To address this, we will "lift" the entire n-gram indexing and analysis workflow into the "Nix matrix." This will transform the process from a manual task into a fully automated, reproducible, and auditable set of Nix derivations.

The proposed solution involves three main parts:

1.  **Nix-Managed Index Generation:** A Nix package will be created to produce the `ngram_index.json` file. This derivation will take the project's `scripts` and `docs` directories as inputs, ensuring that any change to the source files automatically results in a new index.
2.  **Nix-Managed Analysis:** A second Nix package will be created to perform the top-10 analysis. This derivation will depend on the index package, taking its `ngram_index.json` as input and producing a text file with the analysis results.
3.  **Flake App Integration:** The existing `analyze-ngrams` flake app will be updated to simply display the final result of the analysis derivation.

This creates a complete, end-to-end audit trail. The final result is a "proof" that is a pure function of the source code inputs, embodying the core principles of Nix.

## 3. Scope

### In Scope

-   Creation of a new Nix package (`ngram-index`) to generate `ngram_index.json`.
-   Creation of a new Nix package (`top-10-ngrams`) to analyze the index and produce a result file.
-   Modification of the project's `flake.nix` to include these new packages and their dependency relationship.
-   Updating the existing `analyze-ngrams` app to present the result of the `top-10-ngrams` derivation.
-   Refactoring the `generate_ngram_index.sh` and `analyze_ngrams.sh` scripts to work within a Nix derivation context (e.g., accepting input/output paths as arguments).

### Out of Scope

-   Expanding the analysis beyond the top 10 n-grams.
-   Introducing new types of source directories into the index.
-   Creating a user-facing search interface.

## 4. Technical Details

-   The `ngram-index` package will use `pkgs.stdenv.mkDerivation`. Its builder will be a shell script that recursively finds files in the source directories and generates the JSON index.
-   The `top-10-ngrams` package will also use `pkgs.stdenv.mkDerivation`. Its builder will be the `analyze_ngrams.sh` script, which will be modified to read from the path of the `ngram-index` output.
-   The `flake.nix` will be updated to define these packages, with `top-10-ngrams` referencing the output of `ngram-index`.

## 5. Testing Plan

-   The `nix build .#top-10-ngrams` command will be used to verify that the entire dependency chain builds successfully.
-   The output file from the `top-10-ngrams` build will be inspected to ensure it contains the expected analysis results.
-   A small change will be made to a source file in the `scripts` directory to confirm that Nix triggers a rebuild of the index and the analysis.

## 6. Rollback Plan

-   The changes to `flake.nix` can be reverted.
-   The new CRQ file can be deleted.
