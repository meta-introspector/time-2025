# Detailed Task Plan for Bootstrap Context and Rust Crates

This document outlines the plan for completing the manual conversion of `.gitmodules` content into `bootstrap-context.nix` and initiating the Rust code extraction and Nix wrapping process.

## Part 1: Completing `bootstrap-context.nix` Manual Conversion (7 Parts)

**Current Status:**

We have processed `context/pick-up-nix/.gitmodules` and the first four parts of `context/streamofrandom/.gitmodules`. This content is currently being written into `10/10/bootstrap-context.nix` as a single file. The user has requested to break it into 7 parts, each in its own file within `10/10/bootstrap-context/`.

**Goal:**

To manually convert all submodule information from `context/pick-up-nix/.gitmodules` and `context/streamofrandom/.gitmodules` into a structured Nix attribute set, split across 7 separate files, and then compose them into a main `10/10/bootstrap-context.nix`.

**Steps:**

1.  **Create `10/10/bootstrap-context/` directory:** (Already done)

2.  **Move existing content to `part1.nix` to `part5.nix`:**
    *   Move the content from `context/pick-up-nix/.gitmodules` into `10/10/bootstrap-context/part1.nix`.
    *   Move the first part of `context/streamofrandom/.gitmodules` into `10/10/bootstrap-context/part2.nix`.
    *   Move the second part of `context/streamofrandom/.gitmodules` into `10/10/bootstrap-context/part3.nix`.
    *   Move the third part of `context/streamofrandom/.gitmodules` into `10/10/bootstrap-context/part4.nix`.
    *   Move the fourth part of `context/streamofrandom/.gitmodules` into `10/10/bootstrap-context/part5.nix`.

3.  **Process remaining `context/streamofrandom/.gitmodules` content:**
    *   **Part 6:** Extract the next section of submodules from `context/streamofrandom/.gitmodules` and write it to `10/10/bootstrap-context/part6.nix`.
    *   **Part 7:** Extract the final section of submodules from `context/streamofrandom/.gitmodules` and write it to `10/10/bootstrap-context/part7.nix`.

4.  **Create main `10/10/bootstrap-context.nix`:**
    *   This file will import all `partX.nix` files.
    *   It will combine their attribute sets into a single, comprehensive `bootstrapContext` attribute set.

5.  **Stage and Commit:** Stage all new and modified files, and commit with a descriptive message.

## Part 2: Rust Code Extraction and Nix Wrapping

**Goal:**

To extract all Rust code from the mirrored repositories, wrap each Cargo crate in a Nix derivation, organize them in a content-addressable hierarchy under `10/10/crates`, and eliminate multiple usage of Cargo crates.

**Steps:**

1.  **Define `10/10/github/` structure:** (Already done - directory created)

2.  **Enhance `nix-url-extractor.nix`:**
    *   Modify `nix-url-extractor.nix` to return `repoFileInstructions` (path and content) for generating `repo.nix` files for each unique GitHub URL.

3.  **Implement `repo.nix` generation:**
    *   Create a Nix expression (e.g., `10/10/nix2/generate-repos.nix`) that takes the `repoFileInstructions` from `nix-url-extractor.nix` and uses `pkgs.writeText` to create the actual `repo.nix` files in `10/10/github/owner/repo-name.nix`.

4.  **Update `prelude.nix`:**
    *   Modify `prelude.nix` to import `generate-repos.nix` and dynamically import all generated `repo.nix` files from `10/10/github/`.

5.  **Rust Code Discovery:**
    *   Develop a mechanism (e.g., a Nix function or a shell script wrapped in Nix) to traverse the mirrored repositories (`10/10/github/`) and identify Rust projects (e.g., by looking for `Cargo.toml` files).

6.  **Crate Extraction and Normalization:**
    *   For each identified Rust project, extract individual Cargo crates and their dependencies.
    *   Normalize crate names and versions.

7.  **Nix Wrapper Generation for Crates:**
    *   Create Nix functions or templates to generate Nix derivations for each unique Cargo crate.
    *   These wrappers should define how to build and integrate the Rust crates into the Nix ecosystem.

8.  **Content-Addressable Hierarchy (`10/10/crates`):**
    *   Design a content-addressable directory structure under `10/10/crates` for the Nix-wrapped Rust crates.
    *   Consider topological ordering, especially for `syn` and `procmacros` users, to ensure correct dependency resolution.

9.  **Eliminate Multiple Usage of Cargo Crates:**
    *   Integrate checks into the `first-reflection.nix` and `task.nix` modules to enforce the First Principle of Identity for Rust crates.
    *   Identify duplicate crate definitions or usages and report them.

10. **Stage and Commit:** Stage all new and modified files, and commit with descriptive messages for each logical step.