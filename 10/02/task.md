# Tasks for October 2, 2025

This document outlines the immediate tasks to be addressed, prioritizing the resolution of the persistent Nix flake syntax error and continuing the refactoring process.

## High Priority

1.  **Debug `flakes/foaf/aggregator/flake.nix` Syntax Error:** Thoroughly investigate and resolve the persistent `syntax error, unexpected end of file, expecting ';'` in `flakes/foaf/aggregator/flake.nix`. This is the highest priority.
    *   1.1. Review Nix Language Specification: Re-read relevant sections of the Nix language manual regarding flake structure, `outputs` function, `eachDefaultSystem`, and semicolon rules.
    *   1.2. Examine `flake-utils` Source Code: Inspect the `flake-utils` repository (specifically `eachDefaultSystem` implementation) to understand its expected return structure.
    *   1.3. Create Minimal Reproducible Example: Develop a bare-bones `flake.nix` that uses `flake-utils.lib.eachDefaultSystem` and exhibits the same error.
    *   1.4. Test Minimal Example with `nix eval`: Use `nix eval` with `--show-trace` on the minimal example to get more detailed error information.
    *   1.5. Test Minimal Example with `nix flake check`: Use `nix flake check` on the minimal example.
    *   1.6. Consult Nix Community Resources: Search NixOS Discourse, GitHub issues, and Stack Overflow for similar "unexpected end of file, expecting ';'" errors in flakes.
    *   1.7. Verify Nix Version Compatibility: Ensure the Nix version being used is compatible with the flake features and `flake-utils` version.
    *   1.8. Check for Hidden Characters: Use a tool like `cat -v` or a hex editor to check for any invisible or non-printable characters in `flakes/foaf/aggregator/flake.nix` that might be causing parsing issues.
    *   1.9. Re-type the File Manually: As a last resort, manually re-type the `flakes/foaf/aggregator/flake.nix` file to rule out any subtle encoding or character issues.
    *   1.10. Isolate `outputs` Section: Temporarily simplify the `outputs` section to return a simple set (e.g., `{ foo = "bar"; }`) to see if the error persists, then gradually reintroduce complexity.
    *   1.11. Verify `inputs` Section Correctness: Double-check all URLs and refs in the `inputs` section of `flakes/foaf/aggregator/flake.nix` for any subtle errors.
    *   1.12. Check Parent Flake (`root flake.nix`) for Issues: Ensure the way `foafAggregatorFlake` is imported and used in the root `flake.nix` is not introducing the error.
    *   1.13. Test `foafContextFlake` and `foafSeedDataFlake` Independently: Verify that the inputs to the aggregator flake (`foafContextFlake` and `foafSeedDataFlake`) can be evaluated independently without errors.
    *   1.14. Review `let ... in` Block: Ensure the `let ... in` block within `eachDefaultSystem` is correctly structured.
    *   1.15. Examine `pkgs.lib` Usage: Confirm that `pkgs.lib` is being used correctly and not causing any unexpected behavior.
    *   1.16. Consider `nixpkgs` and `flake-utils` Versions: Although the URLs are fixed, ensure there isn't a subtle version incompatibility between `nixpkgs` and `flake-utils` that could manifest as a syntax error.
    *   1.17. Document Findings and Hypotheses: Keep a detailed log of all debugging steps, observations, and hypotheses to aid in problem-solving.
2.  **Investigate and Resolve CRQ-042: Nix Flake Attribute Path Resolution Issue:** Address the persistent attribute path resolution error in `flakes/foaf/aggregator/flake.nix` as documented in `docs/crqs/CRQ_042_Nix_Flake_Attribute_Path_Resolution_Issue.md`.

## FOAF Refactoring

2.  **Refactor `09/foaf.nix`:** Replace direct imports with references to new single-concept flakes (e.g., `github-data`, `crq-aggregator`).
3.  **Create `flakes/foaf/github-data/flake.nix`:** Encapsulate the logic for importing GitHub FOAF data (`github.foaf.nix`, `fetchGithubData`, `githubToFoaf`).
4.  **Create `flakes/foaf/crq-data/crq-XXX/flake.nix` (multiple):** Convert each individual `crq-XXX.foaf.nix` file into its own single-concept flake.
5.  **Create `flakes/foaf/crq-aggregator/flake.nix`:** A flake responsible for aggregating all the individual CRQ flakes into a single structure.
6.  **Update `flakes/foaf/aggregator/flake.nix`:** Integrate the newly created `github-data` and `crq-aggregator` flakes as inputs and combine their outputs into the `fullGraph`.
7.  **Create `flakes/foaf/query-helpers/flake.nix`:** Encapsulate the `findEntitiesByType` and `findProjectsByMaker` helper functions.
8.  **Update `flakes/foaf/aggregator/flake.nix`:** Integrate the `query-helpers` flake and expose its functions.
9.  **Create `flakes/foaf/api/flake.nix`:** A top-level FOAF flake that exposes the final aggregated FOAF API (raw data, query functions).

## General Nix & Project Maintenance

10. **Update Root `flake.nix`:** Add all new FOAF-related flakes (`github-data`, `crq-aggregator`, `query-helpers`, `api`) as inputs and expose their relevant outputs.
11. **Update `Makefile`:** Add new targets for building/evaluating the newly created FOAF flakes and the final FOAF API.
12. **Address `crq-binstore` path inputs:** Systematically replace all commented-out `path:` inputs (e.g., in `nix-llm-task/flake.nix`) with appropriate `github:meta-introspector` URLs (once available or defined).
13. **Fix remaining Nix URL policy violations:** Continue iterating through and resolving any new `nix-url-check` errors that may arise from further refactoring or previously missed files.

## Documentation & Onboarding

14. **Review and update `GEMINI.md`:** Ensure the main `GEMINI.md` operational guidelines and context accurately reflect the new Nixification workflow and project structure.
15. **Review `README.md`:** Update the main `README.md` to provide an overview of the new flake-based architecture and how to get started.
16. **Review `docs/tutorials/`:** Create an "onboarding guide for n00bs" that explains the new flake structure, the "one concept per flake" principle, and how to contribute.
17. **Ensure `docs/memos/Shellcheck_Always_After_Changes.md` is properly referenced:** Integrate this memo into relevant Standard Operating Procedures (SOPs) to emphasize its importance.

## Project Integration

18. **Integrate Project Components into Flake:** Use Nix tools to index all Nix packages in `~/pick-up-nix2/index/file_nix.txt`, understand their graphs, and make a report.
19. **Define Packages/Applications within Flake:** Clearly define and expose all main packages and applications within the top-level flake, ensuring they are easily discoverable and buildable.