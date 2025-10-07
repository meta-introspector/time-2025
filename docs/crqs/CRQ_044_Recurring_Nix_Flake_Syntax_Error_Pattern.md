# CRQ-044: Recurring Nix Flake Syntax Error Pattern

## Title
Recurring Syntax Error Pattern in Nix Flakes Using `flake-utils.lib.eachDefaultSystem`

## Status
Open

## Date
October 2, 2025

## Description

This Change Request documents a recurring and persistent syntax error pattern encountered in multiple Nix flakes that utilize `flake-utils.lib.eachDefaultSystem`. The error consistently manifests as `error: syntax error, unexpected end of file, expecting ';'` or `error: syntax error, unexpected ')', expecting ';'` at the very end of the flake's `outputs` section, specifically at the closing parenthesis of the `eachDefaultSystem` call or the final closing brace of the flake.

### Context

This error was initially encountered and seemingly resolved in `flakes/foaf/aggregator/flake.nix` (documented in CRQ-042). However, the same error has now reappeared in `flakes/foaf/github-data/flake.nix` during its initial evaluation. Despite extensive debugging, including simplifying flakes to their absolute minimum and gradually reintroducing components, the exact root cause of this persistent syntax error remains elusive.

### Problem

Nix's parser consistently reports a syntax error at the end of flakes that use `flake-utils.lib.eachDefaultSystem`, even when the flake's content is minimal and appears syntactically correct according to standard Nix flake examples. This suggests a subtle interaction or a misunderstanding of how Nix or `flake-utils` expects the `outputs` section to be structured in certain contexts.

## Goal

The primary goal of this CRQ is to definitively identify and resolve the root cause of this recurring syntax error pattern, ensuring that flakes using `flake-utils.lib.eachDefaultSystem` can be reliably parsed and evaluated.

## Proposed Solution / Next Steps

1.  **Systematic Debugging of `flakes/foaf/github-data/flake.nix`:** Apply the same iterative debugging strategy that was used for `flakes/foaf/aggregator/flake.nix`:
    *   Simplify `flakes/foaf/github-data/flake.nix` to its absolute minimum (e.g., `outputs = { ... }: { foo = "bar"; };`).
    *   Gradually reintroduce components (inputs, `let ... in` block, variable definitions, `lib` output) one by one, re-running `nix eval` after each step, until the error reappears.
2.  **Deep Dive into `flake-utils`:** If the error reappears during the reintroduction of `flake-utils.lib.eachDefaultSystem`, perform a deeper investigation into the `flake-utils` source code and its interaction with the Nix parser.
3.  **Nix Parser Behavior Analysis:** Investigate how the Nix parser handles the `outputs` section when `eachDefaultSystem` is used, particularly focusing on potential edge cases or implicit behaviors.
4.  **Consult Nix Community:** If the problem remains unresolved after internal investigation, seek assistance from the Nix community (e.g., NixOS Discourse, GitHub issues).

## Impact

Resolution of this issue is critical for the successful implementation of single-concept flakes across the project, as it directly impacts the ability to define and evaluate flake outputs reliably. This CRQ is a blocker for further FOAF refactoring and other Nixification efforts.

## Related CRQs

-   CRQ-041: Nix Flake Refactoring and Topological Makefile
-   CRQ-042: Nix Flake Attribute Path Resolution Issue
