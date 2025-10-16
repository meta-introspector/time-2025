# Task: Implement and Integrate Rust Flake Auditor

## Goal

Develop a Rust-based `flake_auditor` tool that can consume lists of `flake.lock` and `flake.nix` files from the Nix store, parse the `flake.nix` files into ASTs, and then generate an "inverted tree" index of constants and paths. This tool will be orchestrated by a Nix flake.

## Phase 1: Implement the Rust Tool (`flake_auditor`)

**Location:** `10/14/audit-with-rust/flake_auditor/` (assuming this is where the Rust project will reside, or a new directory if `flake_auditor` is a new project within `10/14/audit-with-rust/`)

**Steps:**

1.  **Initialize Rust Project (if not already done):**
    *   Ensure a `Cargo.toml` and `src/main.rs` exist.

2.  **Add Dependencies:**
    *   Add `rnix` (for Nix AST parsing) to `Cargo.toml`.
    *   Add `clap` (for command-line argument parsing) to `Cargo.toml`.
    *   Add `serde` and `serde_json` (for JSON serialization/deserialization) to `Cargo.toml`.

3.  **Implement `flake_auditor` Logic (`src/main.rs`):**
    *   **Argument Parsing:** Use `clap` to parse command-line arguments:
        *   `--lock-files <PATH>`: Path to a file containing a newline-separated list of `flake.lock` paths.
        *   `--nix-files <PATH>`: Path to a file containing a newline-separated list of `flake.nix` store paths.
        *   `--output <PATH>`: Output path for the generated JSON audit report.
    *   **Read Input Lists:** Read the contents of `--lock-files` and `--nix-files` into `Vec<PathBuf>`.
    *   **Core Processing Loop:**
        *   Iterate through each `lock_file_path` from the `--lock-files` input.
        *   **Infer `flake.nix` Path:** For each `lock_file_path`, determine the corresponding `flake.nix` path. A simple heuristic is `lock_file_path.parent().join("flake.nix")`.
        *   **Validate `flake.nix` Path:** Check if the inferred `flake.nix` path exists and is present in the `--nix-files` list (for robustness, though not strictly required for this task).
        *   **Read and Parse `flake.nix`:** Read the content of the `flake.nix` file and use `rnix::Root::parse()` to get its AST. Handle potential parsing errors.
        *   **AST Traversal and Inversion:**
            *   Implement logic to traverse the `rnix` AST.
            *   Identify and extract "constants" (e.g., literal strings, integers, booleans, paths, URLs) and "paths" (attribute paths like `pkgs.lib.foo`).
            *   Build an "inverted index" data structure. This structure should map each discovered constant/path to a list of `flake.nix` files where it appears.
            *   Consider how to represent the "inverted tree" structure. This might involve mapping constants/paths to their usage contexts (e.g., parent nodes, attribute names).
    *   **Output Generation:** Serialize the resulting inverted index into a pretty-printed JSON format and write it to the `--output` path.

## Phase 2: Orchestrate with Nix (`10/15/rust-audit/flake.nix`)

**Location:** `10/15/rust-audit/flake.nix`

**Steps:**

1.  **Ensure `flake_auditor` is buildable:**
    *   Verify that `10/14/audit-with-rust/flake.nix` correctly builds the `flake_auditor` Rust project and exposes it as a package (e.g., `flake_auditor_flake.packages.${system}.flake-auditor`).

2.  **Update `10/15/rust-audit/flake.nix`:**
    *   **Inputs:**
        *   `flake_lock_list_file`: Input for the file containing `flake.lock` paths (e.g., `path:./flake.lock.txt`).
        *   `flake_nix_store_list_file`: Input for the file containing `flake.nix` store paths (e.g., `path:./flake.nix.store`).
    *   **`packages.default` Derivation:**
        *   Build the `flake_auditor` executable.
        *   Invoke the `flake_auditor` executable, passing it the `flake_lock_list_file` and `flake_nix_store_list_file` as arguments.
        *   Direct the output of `flake_auditor` to `$out/audit-report.json`.
    *   **`apps.default`:**
        *   Configure the default app to `cat` the `$out/audit-report.json` file.

## Phase 3: Generate Input Files (Manual Step)

**Steps:**

1.  **Generate `flake.lock` list:**
    ```bash
    find ~/nix/ -type f -name flake.lock > ~/nix/index/flake.lock.txt
    ```
2.  **Generate `flake.nix` store list:**
    ```bash
    find /nix/store/ -type f -name flake.nix > ~/nix/index/flake.nix.store
    ```
    *Note: These commands should be run from the user's shell, not within the agent's environment, as they involve traversing the entire Nix store.*

## Phase 4: Testing and Verification

**Steps:**

1.  **Build the orchestrator flake:**
    ```bash
    nix build ./10/15/rust-audit
    ```
2.  **Run the orchestrator app:**
    ```bash
    nix run ./10/15/rust-audit
    ```
    *   Inspect the JSON output to ensure it contains the expected inverted index.
