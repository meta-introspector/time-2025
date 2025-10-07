# CRQ-042: Nix Flake Attribute Path Resolution Issue

## Title
Persistent Attribute Path Resolution Issue in `flakes/foaf/aggregator/flake.nix`

## Status
Resolved

## Resolution Summary

The persistent attribute path resolution issue was resolved by correctly understanding how `flake-utils.lib.eachDefaultSystem` structures its outputs. The error message `packages.aarch64-linux.aarch64-linux.lib.fullGraph` was misleading. The correct way to access attributes from a flake using `eachDefaultSystem` is `flake.<system>.<attribute>`. The root `flake.nix` was updated to correctly access `foafAggregatorFlake.${system}.lib.fullGraph`.

## Date
October 2, 2025

## Description

This Change Request documents a persistent issue encountered during the refactoring of Nix flakes, specifically within the `flakes/foaf/aggregator/flake.nix` file. Despite numerous attempts to simplify the flake's content and structure, and to correct perceived syntax errors, the `nix eval` command consistently fails with an attribute path resolution error.

### Error Message

`error: flake 'git+file:///.../flakes/foaf/aggregator' does not provide attribute 'packages.aarch64-linux.aarch64-linux.lib.fullGraph', 'legacyPackages.aarch64-linux.aarch64-linux.lib.fullGraph' or 'aarch64-linux.lib.fullGraph'`

### Context

The `flakes/foaf/aggregator/flake.nix` is intended to aggregate outputs from other single-concept FOAF flakes (e.g., `foafContextFlake`, `foafSeedDataFlake`) and expose a `lib.fullGraph` attribute. It utilizes `flake-utils.lib.eachDefaultSystem` to provide system-specific outputs.

Initial debugging efforts focused on a `syntax error, unexpected ')', expecting ';'` which was eventually resolved by simplifying the flake's content. However, upon restoring the full content, the current attribute path resolution error emerged.

### Problem

When attempting to evaluate `.#aarch64-linux.lib.fullGraph` from the `flakes/foaf/aggregator/flake.nix`, Nix reports that the attribute is not found. The error message suggests that Nix is looking for the `aarch64-linux` attribute twice in the path (e.g., `packages.aarch64-linux.aarch64-linux.lib.fullGraph`), which is unexpected given the typical output structure of `flake-utils.lib.eachDefaultSystem`.

This indicates a misunderstanding of how `flake-utils.lib.eachDefaultSystem` structures its output, or a subtle interaction with the flake's inputs or arguments.

## Proposed Solution / Next Steps

1.  **Detailed Output Inspection:** Use `nix eval --json ./flakes/foaf/aggregator` (without specifying an attribute) to get the complete JSON output structure of the flake. This will provide an unambiguous view of how attributes are actually organized.
2.  **Refine Attribute Path:** Based on the detailed output, correct the attribute path used in the `Makefile` target `debug-aggregator-flake` and the root `flake.nix` to accurately access `lib.fullGraph`.
3.  **Review `flake-utils` Documentation:** Re-read the official documentation and common usage patterns for `flake-utils.lib.eachDefaultSystem` to ensure our understanding of its output structure is correct.
4.  **Simplify Inputs (if necessary):** If the issue persists, temporarily remove all inputs from `flakes/foaf/aggregator/flake.nix` except `flake-utils` and gradually reintroduce them to identify if a specific input is causing unexpected behavior in attribute resolution.
5.  **Consult Nix Community:** If the problem remains unresolved after internal investigation, seek assistance from the Nix community (e.g., NixOS Discourse, GitHub issues).

## Impact

Resolution of this issue is critical for the successful refactoring of the FOAF-related Nix flakes into single-concept units, which is a foundational step for CRQ-041 and the overall project's Nixification strategy.

## Related CRQs

-   CRQ-041: Nix Flake Refactoring and Topological Makefile
