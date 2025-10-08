# SOP: Running Nix Tools (`statix`, `make`, and CRQ-related tools)

## 1. Introduction

This Standard Operating Procedure (SOP) outlines the steps for effectively using key Nix-related tools within the project: `statix` for Nix code linting, `make` for orchestrating various build and development tasks, and the project's custom CRQ (Change Request) management tools. Adhering to these guidelines ensures consistency, code quality, and efficient workflow.

## 2. Prerequisites

Before proceeding, ensure you have the following installed and configured:
*   **Nix:** The Nix package manager.
*   **Git:** The Git version control system.

## 3. Running `statix` (Nix Code Linting)

`statix` is used to lint Nix expressions, helping to identify potential issues and enforce coding standards.

### 3.1. Linting All Nix Files in the Project

To lint all Nix files in the current project directory and its subdirectories, use the `lint-nix` make target:

```bash
make lint-nix
```

*   **Output:** The results of the `statix` check will be saved to `statix_output.txt` in the project root.

### 3.2. Linting a Specific Nix File

To run `statix` on a particular Nix file, use the `nix run` command directly:

```bash
nix run github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify#statix -- check <path/to/file.nix>
```

*   **Example:**
    ```bash
    nix run github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify#statix -- check 10/03/hackathon_71_parts.nix
    ```

### 3.3. Shell Script Linting with `shellcheck`

While `statix` focuses on Nix expressions, `shellcheck` is crucial for maintaining the quality and correctness of our shell scripts. It helps identify common pitfalls, syntax errors, and stylistic issues in `bash`, `sh`, and other shell scripts.

*   **Action:** Always run `shellcheck` on any shell script you create or modify.
*   **Tool:** `shellcheck`
*   **Frequency:** As part of pre-commit hooks, and whenever shell scripts are modified.
*   **Expected Result:** No errors or warnings reported by `shellcheck`.
*   **Reference:** For a detailed reminder on why and when to run `shellcheck`, please refer to the memo: `docs/memos/Shellcheck_Always_After_Changes.md` (located in the main `pick-up-nix2` project).

## 4. Using `make` for Project Tasks

The project's `Makefile` defines various targets to automate common development and build tasks.

### 4.1. General Usage

To execute a `make` target, use the following command:

```bash
make <target-name>
```

### 4.2. Important: `pre-nix-check`

Many `make` targets include a `pre-nix-check` step. This check ensures that there are no unstaged or uncommitted Nix files before proceeding with Nix-related operations. This is crucial for maintaining build purity and reproducibility. If this check fails, you must commit or stash your Nix file changes before retrying.

### 4.3. Common Nix-Related `make` Targets

Here are some frequently used `make` targets:

*   **`build-foaf-context`**: Builds the FOAF context flake.
*   **`install-hooks`**: Installs pre-commit Git hooks within the Nix development environment.
*   **`git-commit`**: Runs `git commit` within the Nix development environment, expecting a commit message in `commit_message.txt`.
*   **`strace-git-commit`**: Runs `git commit` with `strace` to debug pre-commit hook issues, outputting to `strace.txt`.
*   **`reproduce-nix-segfault`**: Reproduces Nix segmentation faults and captures logs for debugging.

## 5. Using CRQ-related Nix Tools

The project includes several Nix-based tools for managing and interacting with CRQ (Change Request) documents.

### 5.1. Checking CRQ Document Existence

This tool verifies the existence of CRQ/Incident/Task documents referenced in a commit message. It's typically used as part of pre-commit hooks.

```bash
make check-crq-document COMMIT_MSG_FILE=<path/to/commit_message.txt>
```

### 5.2. Testing CRQ Document Existence Check

To test the CRQ document existence check script independently:

```bash
make test-crq-document-check COMMIT_MSG_FILE=<path/to/commit_message.txt>
```

### 5.3. Testing CRQ Search Function

To test the `crq-search.nix` function with an optional keyword:

```bash
make test-crq-search [KEYWORD="your_keyword"]
```

*   **Example:**
    ```bash
    make test-crq-search KEYWORD="flake"
    ```

### 5.4. Searching CRQs

To search for CRQs based on a keyword or list the latest suggestions:

```bash
make search-crqs [KEYWORD="your_keyword"]
```

*   **Example:**
    ```bash
    make search-crqs KEYWORD="nixification"
    ```

### 5.5. Listing CRQs

To list CRQs with optional keyword filtering and control the number of suggestions:

```bash
make list-crqs [KEYWORD="your_keyword"] [NUM_SUGGESTIONS=3]
```

*   **Example:**
    ```bash
    make list-crqs KEYWORD="documentation" NUM_SUGGESTIONS=5
    ```
