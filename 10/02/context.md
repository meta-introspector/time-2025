# Context Dump - October 2, 2025

This document summarizes the current state of the project and outlines the immediate next steps, particularly focusing on the Nix flake refactoring and the persistent syntax error.

## Current Status

The primary goal is to refactor existing Nix packages to adhere to a "one concept per flake" principle, using only `github:meta-introspector` sources or the Nix store, and managing builds via a topological Makefile.

### Progress Made:
-   **Nix URL Policy Enforcement:** A pre-commit hook (`nix_url_check.sh`) has been implemented and refined to ensure all `nixpkgs.url` and `flake-utils.url` inputs point to `github:meta-introspector` forks with the `feature/CRQ-016-nixify` ref. This hook is now working correctly and has helped identify and fix several policy violations in various `flake.nix` files.
-   **FOAF Context Flake:** `flakes/foaf/context/flake.nix` has been created to encapsulate the FOAF context URI.
-   **FOAF Seed Data Flake:** `flakes/foaf/seed-data/flake.nix` has been created to encapsulate the seed FOAF agents and projects.
-   **FOAF Aggregator Flake (Initial):** `flakes/foaf/aggregator/flake.nix` has been created to aggregate the FOAF context and seed data.
-   **Root Flake Updates:** The main `flake.nix` has been updated to include `foafContextFlake`, `foafSeedDataFlake`, and `foafAggregatorFlake` as inputs, and to expose their relevant outputs.
-   **Makefile Integration:** The `Makefile` now includes targets (`build-foaf-context`, `build-foaf-seed-data`, `build-foaf-full-graph`) to evaluate these new flakes.
-   **Git Hygiene:** The `Makefile` includes a `pre-nix-check` to ensure no unstaged or uncommitted Nix files before running Nix commands.

### Persistent Issue:
-   **`flakes/foaf/aggregator/flake.nix` Syntax Error:** Despite multiple attempts to fix it, the `make build-foaf-full-graph` command consistently fails with `error: syntax error, unexpected end of file, expecting ';'` at the last line of `flakes/foaf/aggregator/flake.nix`. This indicates a fundamental issue with the flake's structure or Nix's interpretation of it.

## Remaining Tasks (19 Tasks)

1.  **Debug `flakes/foaf/aggregator/flake.nix` Syntax Error:** Thoroughly investigate and resolve the persistent `syntax error, unexpected end of file, expecting ';'` in `flakes/foaf/aggregator/flake.nix`. This is the highest priority.
2.  **Refactor `09/foaf.nix`:** Replace direct imports with references to new single-concept flakes (e.g., `github-data`, `crq-aggregator`).
3.  **Create `flakes/foaf/github-data/flake.nix`:** Encapsulate the logic for importing GitHub FOAF data (`github.foaf.nix`, `fetchGithubData`, `githubToFoaf`).
4.  **Create `flakes/foaf/crq-data/crq-XXX/flake.nix` (multiple):** Convert each individual `crq-XXX.foaf.nix` file into its own single-concept flake.
5.  **Create `flakes/foaf/crq-aggregator/flake.nix`:** A flake responsible for aggregating all the individual CRQ flakes into a single structure.
6.  **Update `flakes/foaf/aggregator/flake.nix`:** Integrate the newly created `github-data` and `crq-aggregator` flakes as inputs and combine their outputs into the `fullGraph`.
7.  **Create `flakes/foaf/query-helpers/flake.nix`:** Encapsulate the `findEntitiesByType` and `findProjectsByMaker` helper functions.
8.  **Update `flakes/foaf/aggregator/flake.nix`:** Integrate the `query-helpers` flake and expose its functions.
9.  **Create `flakes/foaf/api/flake.nix`:** A top-level FOAF flake that exposes the final aggregated FOAF API (raw data, query functions).
10. **Update Root `flake.nix`:** Add all new FOAF-related flakes (`github-data`, `crq-aggregator`, `query-helpers`, `api`) as inputs and expose their relevant outputs.
11. **Update `Makefile`:** Add new targets for building/evaluating the newly created FOAF flakes and the final FOAF API.
12. **Address `crq-binstore` path inputs:** Systematically replace all commented-out `path:` inputs (e.g., in `nix-llm-task/flake.nix`) with appropriate `github:meta-introspector` URLs (once available or defined).
13. **Fix remaining Nix URL policy violations:** Continue iterating through and resolving any new `nix-url-check` errors that may arise from further refactoring or previously missed files.
14. **Review and update `GEMINI.md`:** Ensure the main `GEMINI.md` operational guidelines and context accurately reflect the new Nixification workflow and project structure.
15. **Review `README.md`:** Update the main `README.md` to provide an overview of the new flake-based architecture and how to get started.
16. **Review `docs/tutorials/`:** Create an "onboarding guide for n00bs" that explains the new flake structure, the "one concept per flake" principle, and how to contribute.
17. **Ensure `docs/memos/Shellcheck_Always_After_Changes.md` is properly referenced:** Integrate this memo into relevant Standard Operating Procedures (SOPs) to emphasize its importance.
18. **Integrate Project Components into Flake:** Use Nix tools to index all Nix packages in `~/pick-up-nix2/index/file_nix.txt`, understand their graphs, and make a report.
19. **Define Packages/Applications within Flake:** Clearly define and expose all main packages and applications within the top-level flake, ensuring they are easily discoverable and buildable.
