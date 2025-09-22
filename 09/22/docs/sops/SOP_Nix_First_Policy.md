# SOP: Adhering to the Nix-First Development Policy

## 1. Purpose

This Standard Operating Procedure (SOP) provides guidelines for developers to adhere to the "Nix-First Development and Immutable State Policy" (CRQ-017). It outlines how to ensure scripts are run in Nix, how to define composable tools with flakes, and how to maintain an immutable project state.

## 2. Policy Overview (CRQ-017)

The "Nix-First" policy mandates that all development, build, and testing processes are managed and executed within Nix environments. Key aspects include:
*   All shell scripts are executed via `nix develop --command`.
*   Tools and components define their own `flake.nix` for composability.
*   The project state aims for immutability through pinned dependencies and reproducible builds.

## 3. Guidelines for Script Execution

*   **Always run shell scripts within a Nix development environment.**
    *   If a script requires specific tools or dependencies, ensure they are listed in the `packages` attribute of the `devShell` in the relevant `flake.nix` file.
    *   Execute scripts using: `nix develop --command <path_to_script> [arguments]`
    *   For scripts that are part of a package built by Nix, they can be invoked directly after `nix build` (e.g., `./result/bin/my-script`).

## 4. Guidelines for Tool and Environment Definition

*   **Each standalone tool or logical component should have its own `flake.nix` file.**
    *   This `flake.nix` should define its build process and its `devShell` with all necessary dependencies.
    *   Use `naersk` for Rust projects to ensure reproducible Rust builds within Nix.
*   **Compose environments as needed.** The root `flake.nix` (or other higher-level flakes) should import and compose these individual tool flakes to create comprehensive development environments.

## 5. Maintaining Immutable Project State

*   **Pin all dependencies:** Regularly update `flake.lock` files to pin all inputs to specific commits. Use `nix flake update` to update inputs and then commit the updated `flake.lock`.
*   **Avoid manual installations:** Do not install tools or dependencies directly on your host system that are part of the Nix environment.
*   **Commit all changes:** Ensure all changes to `flake.nix` and `flake.lock` files, as well as source code, are committed to Git.

## 6. Troubleshooting

*   **"Git tree is dirty" errors during Nix builds:** This often indicates uncommitted changes. Ensure all relevant files are staged and committed before attempting a Nix build.
*   **"No such file or directory" errors for sources:** Verify that the `src` attribute in your `flake.nix` correctly points to the source directory and that the source is properly tracked by Git.
*   **Git lock file issues:** These are caused by parallel Git operations. Ensure scripts execute Git commands sequentially. If a lock file persists, it indicates a crashed process, and manual intervention might be required (though this should be rare with sequential operations).

## 7. Related Documents

*   [CRQ-016: Submodule Nixification and Flake Refactoring](docs/crqs/CRQ_016_Submodule_Nixification.md)
*   [Memo: Use Shellcheck Always After Changes](docs/memos/Shellcheck_Always_After_Changes.md)
*   [CRQ-017: Nix-First Development and Immutable State Policy](docs/crqs/CRQ_017_Nix_First_Development_and_Immutable_State_Policy.md)
*   [Contributing with CRQs and SOPs Tutorial](docs/tutorials/Contributing_with_CRQs_and_SOPs.md)
