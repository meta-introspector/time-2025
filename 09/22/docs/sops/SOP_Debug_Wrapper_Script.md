# SOP: Debug Wrapper Script for LLM Context Generation

## 1. Purpose

This Standard Operating Procedure (SOP) describes the functionality and usage of `debug_wrapper.sh`, a script designed to act as an intermediary between Nix's `buildCommand` and the actual LLM context generation scripts (e.g., `generate_monster_group_llm_txt.sh`, `generate_oeis_llm_txt.sh`). It facilitates debugging by providing a controlled environment for argument parsing and script execution within the Nix build process.

## 2. Scope

This SOP applies to developers and maintainers working with Nix flakes that generate LLM context files, particularly when troubleshooting issues related to script execution or argument passing within the Nix build environment.

## 3. Prerequisites

-   A working Bash environment.
-   Familiarity with Nix build processes and `flake.nix` structure.

## 4. Procedure

The `debug_wrapper.sh` script is not intended to be run directly by users. Instead, it is invoked by Nix during the build of LLM context packages.

### 4.1. Script Location

The script is located at: `/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/22/nix-llm-context/debug_wrapper.sh`

### 4.2. Role in Nix Build

In `nix-llm-context/flake.nix`, the `buildCommand` for LLM context packages (like `monsterGroupLlmContext` and `oeisLlmContext`) calls `debug_wrapper.sh`. This wrapper receives various parameters from the Nix build environment.

### 4.3. Script Functionality

`debug_wrapper.sh` performs the following key functions:

1.  **Argument Parsing**: It parses named arguments passed from the Nix `buildCommand`, including:
    -   `--generator-script`: The path to the actual LLM context generation script (e.g., `generate_oeis_llm_txt.sh`).
    -   `--symbol`: The symbol name for the LLM context (e.g., "OEIS", "Monster Group").
    -   `--html-file-name`: The name of the HTML source file (e.g., `Online_Encyclopedia_of_Integer_Sequences.html`).
    -   `--keywords-script`: The path to the keyword extraction script.
    -   `--links-file-name`: The name of the file containing extracted links.
    -   `--tutorials-pattern`: A glob pattern for related tutorial files.
    -   `--output-dir`: The directory where the final LLM context file should be placed.
    -   `--main-project`: The root path of the main project within the Nix store.
2.  **Variable Initialization**: It initializes all expected variables to empty strings at the beginning to prevent "unbound variable" errors when `set -u` is active.
3.  **Path Construction**: It constructs absolute paths for various input files (HTML, keywords script, links file, tutorials) by combining `MAIN_PROJECT` with their relative paths.
4.  **Execution of Generator Script**: It uses `exec` to replace its own process with the execution of the specified `--generator-script`, passing all parsed arguments to it. This ensures that the generator script runs directly, inheriting the environment set up by the wrapper.
5.  **Debugging Output**: It includes `echo "DEBUG: ..."` statements to print the current working directory and the value of `GENERATOR_SCRIPT`, which are invaluable for debugging path resolution issues within the Nix build environment.

## 5. Debugging

If an LLM context generation build fails, inspect the Nix build log for output from `debug_wrapper.sh`'s `DEBUG:` statements. These can help identify if arguments are being passed correctly and if the generator script is being located at the expected path within the Nix store.

## 6. Related Files

-   `/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/22/nix-llm-context/flake.nix`: Invokes `debug_wrapper.sh` in its `buildCommand`.
-   `/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/22/nix-llm-context/generate_oeis_llm_txt.sh`: An example of a generator script executed by `debug_wrapper.sh`.
-   `/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/22/nix-llm-context/generate_monster_group_llm_txt.sh`: Another example of a generator script executed by `debug_wrapper.sh`.
