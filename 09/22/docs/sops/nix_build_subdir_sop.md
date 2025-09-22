# SOP: Building Nix Flakes in Subdirectories: Troubleshooting and Solutions

## 1. Purpose

This Standard Operating Procedure (SOP) provides guidance and solutions for troubleshooting issues encountered when building Nix flakes located in subdirectories. It addresses common problems related to Nix version compatibility and flake resolution, ensuring modular development and isolated building of components within a larger Nix-managed project.

## 2. Scope

This SOP applies to developers and contributors working with Nix flakes in subdirectories, particularly within projects that utilize Git submodules or other nested flake structures.

## 3. Prerequisites

*   Nix installed on your system.
*   Familiarity with basic Nix flake concepts and commands.

## Problem:
`nix build` and `nix-build` commands fail to build flakes located in subdirectories when executed from within those subdirectories, or when attempting to specify the local flake.

## Symptoms:
Error messages like "cannot find flake 'flake:...' in the flake registries", "unrecognised flag '--flake'", or "path '/data/data/com.termux.nix/files/home/pick-up-nix2/default.nix' does not exist" when attempting to build a sub-flake.

## Root Cause:
The Nix environment's version is too old to fully support modern flake features, particularly the `--flake` flag and proper resolution of flakes in subdirectories of a larger project.

## Impact:
Prevents modular development and isolated building of components within a larger Nix-managed project.

## Solutions:

### Recommended (Long-Term):
**Upgrade Nix Installation**. Upgrade Nix to version 2.4 or newer to enable full flake functionality and the `--flake` flag. This is the most robust and idiomatic solution for modern Nix development.

### Workaround (Short-Term, if upgrade is not immediately possible):

*   **Option A: Build from Root (Explicit Path)**: If the sub-flake is exposed as an attribute in the root `flake.nix`, build it by specifying the full attribute path from the project root (e.g., `nix build .#my-sub-flake`). This requires modifying the root `flake.nix`.
*   **Option B: Build from Root (Temporary Copy)**: Copy the sub-flake's directory to a temporary, isolated location outside the main project, and then build it there. This is a hacky solution and not recommended for regular workflow.

## Verification:
After implementing a solution, verify by successfully building the sub-flake in isolation.

## Related Documents:
*   [CRQ-016: Submodule Nixification and Flake Refactoring](docs/crqs/CRQ_016_Submodule_Nixification.md)
*   [Memo: Use Shellcheck Always After Changes](docs/memos/Shellcheck_Always_After_Changes.md)
