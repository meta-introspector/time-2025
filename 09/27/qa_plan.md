# QA Plan for Recent Project Changes

This QA plan outlines the testing strategy for the recent changes identified in the `recent_changes_summary.md`.

## 1. Build and Dependency Verification

**Objective**: Ensure the project builds successfully with updated dependencies and Nix configurations.

*   **Test Cases**:
    *   **TC-1.1: Clean Build**: Perform a clean build of the `log_analyzer` project using `cargo clean && cargo build`.
        *   **Expected Result**: Build completes successfully without errors.
    *   **TC-1.2: Nix Build**: Perform a Nix build of the `log_analyzer` project using `nix build .#log-analyzer`.
        *   **Expected Result**: Nix build completes successfully, and the resulting executable is functional (e.g., `result/bin/log-analyzer --version`).
    *   **TC-1.3: Dev Shell Entry**: Enter the Nix development shell using `nix develop`.
        *   **Expected Result**: The shell loads correctly, and `cargo`, `rustc`, `rustfmt`, `clippy`, and `openssl` are available in the PATH.
    *   **TC-1.4: Dependency Resolution**: Verify that `Cargo.lock` and `flake.lock` correctly reflect the updated dependencies and meta-introspector forks.
        *   **Expected Result**: No dependency conflicts or unexpected versions are reported during build or `cargo update`.

## 2. New Feature: URL Extractor (`src/url_extractor.rs`)

**Objective**: Verify the functionality of the new URL extraction module.

*   **Test Cases**:
    *   **TC-2.1: Basic URL Extraction**: Provide sample log data (e.g., `telemetry.log`) containing various URL formats (HTTP, HTTPS, with/without paths, query parameters) and verify that `extract_urls` correctly identifies and returns them.
        *   **Expected Result**: All valid URLs are extracted and returned as a list of strings.
    *   **TC-2.2: No URLs Present**: Provide log data without any URLs.
        *   **Expected Result**: `extract_urls` returns an empty list.
    *   **TC-2.3: Malformed URLs**: Provide log data with malformed URL-like strings.
        *   **Expected Result**: `extract_urls` should ideally ignore malformed URLs or handle them gracefully (e.g., not crash).
    *   **TC-2.4: Performance (if applicable)**: For large log files, measure the performance of URL extraction.
        *   **Expected Result**: Extraction completes within acceptable time limits.

## 3. New Binary: Telemetry Manager (`src/bin/telemetry_manager.rs`)

**Objective**: Verify the functionality of the new `telemetry_manager` binary.

*   **Test Cases**:
    *   **TC-3.1: Basic Execution**: Run `telemetry_manager` with minimal arguments (if any are required).
        *   **Expected Result**: The program executes without crashing and provides expected output (e.g., help message, basic status).
    *   **TC-3.2: Data Processing**: If `telemetry_manager` processes telemetry data, provide sample data and verify its output/actions.
        *   **Expected Result**: Data is processed correctly according to its intended logic.
    *   **TC-3.3: Error Handling**: Test with invalid inputs or edge cases.
        *   **Expected Result**: Appropriate error messages or graceful failure.

## 4. Utility Scripts Verification

**Objective**: Ensure the new and modified utility scripts function as expected.

*   **Test Cases**:
    *   **TC-4.1: `getsources.sh` - Default Behavior**: Run `getsources.sh` without arguments.
        *   **Expected Result**: `sources.txt` is created/updated with `telemetry.log` paths from default locations (`$HOME/gemini-cli/.gemini/` and `../../`).
    *   **TC-4.2: `getsources.sh` - Custom Output File**: Run `getsources.sh -o custom_sources.txt`.
        *   **Expected Result**: `custom_sources.txt` is created/updated correctly.
    *   **TC-4.3: `getsources.sh` - Custom Target File**: Run `getsources.sh -t custom.log`.
        *   **Expected Result**: `sources.txt` contains paths to `custom.log` files.
    *   **TC-4.4: `getsources.sh` - Custom Search Path**: Run `getsources.sh /some/other/path`.
        *   **Expected Result**: `sources.txt` contains `telemetry.log` paths from `/some/other/path`.
    *   **TC-4.5: `today.sh` - Symlink Creation**: Run `today.sh`.
        *   **Expected Result**:
            *   `$NIX_HOME/nix/current-month` symlink points to `$NIX_HOME/source/github/meta-introspector/streamofrandom/YYYY/MM`.
            *   `$NIX_HOME/nix/today` symlink points to `$NIX_HOME/source/github/meta-introspector/streamofrandom/YYYY/MM/DD`.
            *   The script outputs the full path to today's directory.
            *   The current working directory changes to today's directory.
    *   **TC-4.6: `today.sh` - Idempotency**: Run `today.sh` multiple times.
        *   **Expected Result**: Symlinks are updated correctly, and no errors occur on subsequent runs.

## 5. Submodule Verification

**Objective**: Confirm that submodules are correctly initialized, updated, and functional.

*   **Test Cases**:
    *   **TC-5.1: Submodule Status**: Run `git submodule status` and `git submodule update --init --recursive`.
        *   **Expected Result**: All submodules are initialized and updated to their correct commits without errors.
    *   **TC-5.2: `PHONEINFOGA` Submodule**: Navigate to `09/25/log_analyzer/osint/PHONEINFOGA` and verify its contents.
        *   **Expected Result**: The submodule directory contains the expected files from the `PHONEINFOGA` repository.

## 6. Documentation Review

**Objective**: Ensure that the deletion of conceptual documentation does not impact critical project understanding or introduce broken references.

*   **Test Cases**:
    *   **TC-6.1: Internal References**: Search the remaining `.md` files and code for any broken links or references to the deleted `bott8_*.md` files.
        *   **Expected Result**: No broken internal references are found. If found, they should be updated or removed.
    *   **TC-6.2: Project Overview**: Review the main `README.md` and other high-level documentation to ensure the project's purpose and architecture are still clearly articulated despite the removal of detailed conceptual files.
        *   **Expected Result**: The project overview remains coherent and sufficient.

---
**Note**: This QA plan assumes a standard development environment with Git, Cargo, and Nix installed and configured.