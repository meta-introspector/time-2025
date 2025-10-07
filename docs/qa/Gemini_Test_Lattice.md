# Gemini Test Lattice: Overview of Impure Gemini-Related Nix Files

This document provides an overview of various Nix files within the project that interact with the Gemini CLI, particularly focusing on their impurity characteristics and how they integrate with Gemini. The goal is to create a "lattice" of tests, allowing for better understanding, selection, and potential merging or removal of duplicate functionalities.

## I. Nix-Task Integrations (Interactive & Basic Execution)

These files define tasks that leverage `nix-task` to run `gemini-cli`, often with `impureEnvPassthrough` for interactive use.

### 1. `./09/26/jobs/vendor/nix-task/nix/tasks/gemini.nix`
*   **Purpose:** Defines an interactive Gemini CLI task (`gemini-cli-interactive`).
*   **Impurity:** Explicitly uses `impureEnvPassthrough = [ "HOME" "TERM" ];` to allow access to host environment variables necessary for interactive shell environments and `gemini-cli` configuration.
*   **Gemini Integration:** Directly runs `nix run ${gemini-cli}#gemini`.
*   **Notes:** Designed for interactive use where `gemini-cli` is expected to find its configuration in `~/.gemini`.
*   **Feature Vector Mapping (from 10/07/plan.md):**
    *   1. Using Home Directory: **Yes** (implicitly, `gemini-cli` expects `~/.gemini`)
    *   2. Using Telemetry: **No**
    *   3. Using OAuth Credentials: **Yes** (implicitly, via `~/.gemini`)
    *   4. Using Nix Base: **Yes**
    *   5. Using a Makefile Target to Generate Input Text: **No**
    *   6. Capturing all output files of the LLM from its working dir: **No**
    *   7. Using YOLO (You Only Live Once) Approval Model: **No**
    *   8. Capturing Telemetry: **No**
    *   9. With its Own Source Code as Input: **No**
    *   10. With Additional URLs or Targets as Hash Inputs: **No**
    *   11. Each Makefile Target is a Derivation: **Yes** (the task itself is a derivation)

### 2. `./09/26/jobs/vendor/nix-task/nix/tasks/run-gemini-cli.nix`
*   **Purpose:** Defines a task (`run-gemini-cli-interactive`) to run `gemini-cli` with an empty prompt.
*   **Impurity:** Uses `impureEnvPassthrough = [ "HOME" "TERM" ];` for host environment access.
*   **Gemini Integration:** Directly runs `nix run ${gemini-cli}#gemini -- --prompt ""`.
*   **Notes:** Likely used for testing basic `gemini-cli` execution or initial setup.
*   **Feature Vector Mapping (from 10/07/plan.md):**
    *   1. Using Home Directory: **Yes** (implicitly, `gemini-cli` expects `~/.gemini`)
    *   2. Using Telemetry: **No**
    *   3. Using OAuth Credentials: **Yes** (implicitly, via `~/.gemini`)
    *   4. Using Nix Base: **Yes**
    *   5. Using a Makefile Target to Generate Input Text: **No**
    *   6. Capturing all output files of the LLM from its working dir: **No**
    *   7. Using YOLO (You Only Live Once) Approval Model: **No**
    *   8. Capturing Telemetry: **No**
    *   9. With its Own Source Code as Input: **No**
    *   10. With Additional URLs or Targets as Hash Inputs: **No**
    *   11. Each Makefile Target is a Derivation: **Yes** (the task itself is a derivation)

## II. Gemini Integration & Telemetry Capture

These files focus on deeper integration with Gemini, including testing the `gemini-cli` bundle and capturing telemetry from API calls.

### 3. `./09/27/7-concepts/2-gemini-integration/working-nix-store-gemini.nix`
*   **Purpose:** Comprehensive example of Gemini integration and telemetry capture, verifying the `gemini-cli` bundle in the Nix store.
*   **Impurity:**
    *   `__impure = true;` for `telemetryCapture` derivation due to network requests and environment variable access.
    *   `GEMINI_API_KEY = builtins.getEnv "GEMINI_API_KEY";` (though the user indicated this is not the primary method for credentials).
*   **Gemini Integration:** Defines `gemini-cli` input, references `geminiStorePath`, `geminiBundle`, `geminiWrapper`, and includes a `telemetryCapture` derivation that runs `geminiWrapper` and captures output, including API testing.
*   **Notes:** This flake is central to understanding how `gemini-cli` components are structured and tested within Nix.
*   **Feature Vector Mapping (from 10/07/plan.md):**
    *   1. Using Home Directory: **No** (relies on `GEMINI_API_KEY` or direct `gemini-cli` invocation)
    *   2. Using Telemetry: **Yes** (explicitly captures telemetry)
    *   3. Using OAuth Credentials: **Yes** (via `GEMINI_API_KEY` or `gemini-cli`'s internal mechanism)
    *   4. Using Nix Base: **Yes**
    *   5. Using a Makefile Target to Generate Input Text: **No**
    *   6. Capturing all output files of the LLM from its working dir: **Yes** (captures `capture.log` and `summary.json`)
    *   7. Using YOLO (You Only Live Once) Approval Model: **No**
    *   8. Capturing Telemetry: **Yes** (redundant with #2, but explicitly stated)
    *   9. With its Own Source Code as Input: **No**
    *   10. With Additional URLs or Targets as Hash Inputs: **No**
    *   11. Each Makefile Target is a Derivation: **Yes** (the `telemetryCapture` is a derivation)

## III. QA Testing & Build-Time Gemini Interaction

These files are test cases specifically designed to interact with `gemini-cli` during the Nix build phase, often involving `sops-nix` for credential management.

### 4. `./09/27/7-concepts/6-qa-testing/tests/2025-01-27-build-time-gemini-capture/flake.nix`
*   **Purpose:** Test case for capturing telemetry during a Nix build that involves `gemini-cli` API calls.
*   **Impurity:**
    *   `__impure = true;` for `buildTimeTelemetry` derivation due to build-time network access and `gemini-cli` execution.
    *   Includes `sops-nix` integration (`sops-nix.url`, `secrets.nix`, `decryptedSopsSecrets`) to provide credentials.
*   **Gemini Integration:** Executes `gemini-cli` (version, help, and actual API call) within the `buildPhase`, capturing telemetry. The prompt for the API call is hardcoded.
*   **Notes:** Demonstrates build-time interaction with Gemini and secure credential injection via `sops-nix`.
*   **Feature Vector Mapping (from 10/07/plan.md):**
    *   1. Using Home Directory: **Yes** (copies decrypted secrets to `$HOME/.gemini/`)
    *   2. Using Telemetry: **Yes** (explicitly captures telemetry)
    *   3. Using OAuth Credentials: **Yes** (via `sops-nix` and `decryptedSopsSecrets`)
    *   4. Using Nix Base: **Yes**
    *   5. Using a Makefile Target to Generate Input Text: **No** (prompt is hardcoded)
    *   6. Capturing all output files of the LLM from its working dir: **Yes** (captures `build-time-capture.log` and `build-time.json`)
    *   7. Using YOLO (You Only Live Once) Approval Model: **No** (no explicit approval model)
    *   8. Capturing Telemetry: **Yes** (redundant with #2, but explicitly stated)
    *   9. With its Own Source Code as Input: **Yes** (`flakeNixContent = builtins.readFile (self + "/flake.nix");`)
    *   10. With Additional URLs or Targets as Hash Inputs: **No**
    *   11. Each Makefile Target is a Derivation: **Yes** (the `buildTimeTelemetry` is a derivation)

### 5. `./09/27/7-concepts/6-qa-testing/tests/consolidated-impure-gemini-telemetry/flake.nix`
*   **Purpose:** Consolidated test case for capturing telemetry from `gemini-cli` in an impure build, with a focus on credential handling.
*   **Impurity:**
    *   `__impure = true;` for `impureGeminiTelemetry` derivation.
    *   Direct execution of `gemini-cli` and network access.
    *   Includes `sops-nix` integration (`decryptedSopsSecrets`) and copies decrypted secrets into a temporary directory.
*   **Gemini Integration:** Runs various `gemini-cli` commands and captures telemetry.
*   **Notes:** Similar to the previous test, but with a focus on consolidated telemetry and credential handling.
*   **Feature Vector Mapping (from 10/07/plan.md):**
    *   1. Using Home Directory: **Yes** (copies decrypted secrets to `/tmp/.gemini`)
    *   2. Using Telemetry: **Yes** (explicitly captures telemetry)
    *   3. Using OAuth Credentials: **Yes** (via `sops-nix` and `decryptedSopsSecrets`)
    *   4. Using Nix Base: **Yes**
    *   5. Using a Makefile Target to Generate Input Text: **No** (prompt is hardcoded)
    *   6. Capturing all output files of the LLM from its working dir: **Yes** (captures `impure-telemetry.log` and `summary.json`)
    *   7. Using YOLO (You Only Live Once) Approval Model: **No** (no explicit approval model)
    *   8. Capturing Telemetry: **Yes** (redundant with #2, but explicitly stated)
    *   9. With its Own Source Code as Input: **No**
    *   10. With Additional URLs or Targets as Hash Inputs: **No**
    *   11. Each Makefile Target is a Derivation: **Yes** (the `impureGeminiTelemetry` is a derivation)

## IV. Gemini Prompt Generation

This file defines a derivation for generating prompts using `gemini-cli` during the Nix build.

### 6. `./10/04/gemini-prompt-flake/gemini-prompt-derivation.nix`
*   **Purpose:** Derivation that runs `gemini-cli` with a given prompt during the Nix build to generate output.
*   **Impurity:**
    *   `__impure = true;` for the main derivation due to build-time network access and `gemini-cli` execution.
    *   Includes `sops-nix` integration (`sops-nix`, `secrets.nix`, `decryptedSopsSecrets`) for credentials.
*   **Gemini Integration:** Takes `gemini-cli` and `prompt` as inputs, executes `gemini-cli` with the prompt, and captures JSON output.
*   **Notes:** A core component for integrating Gemini API calls directly into Nix derivations for prompt generation.
*   **Feature Vector Mapping (from 10/07/plan.md):**
    *   1. Using Home Directory: **Yes** (copies decrypted secrets to `$HOME/.gemini/`)
    *   2. Using Telemetry: **No** (not explicitly captured in this derivation)
    *   3. Using OAuth Credentials: **Yes** (via `sops-nix` and `decryptedSopsSecrets`)
    *   4. Using Nix Base: **Yes**
    *   5. Using a Makefile Target to Generate Input Text: **Yes** (the `prompt` is passed as an argument, which can come from a Makefile target)
    *   6. Capturing all output files of the LLM from its working dir: **Yes** (captures `gemini_output.json`)
    *   7. Using YOLO (You Only Live Once) Approval Model: **No** (no explicit approval model)
    *   8. Capturing Telemetry: **No**
    *   9. With its Own Source Code as Input: **No**
    *   10. With Additional URLs or Targets as Hash Inputs: **No**
    *   11. Each Makefile Target is a Derivation: **Yes** (the `gemini-prompt-output` is a derivation)

## V. Wrapper for Gemini CLI with SOPS Secrets

This flake provides a wrapper for `gemini-cli` that makes `sops`-managed secrets available to it.

### 7. `./flakes/wrap-gemini-secrets/flake.nix`
*   **Purpose:** Provides a `geminiCliWithSecrets` wrapper that sets up a temporary `HOME` directory, copies decrypted secrets into `$HOME/.gemini/`, and then executes the `gemini-cli` command.
*   **Impurity:** The wrapper itself is a shell script, and the overall process involves decryption (which is impure) and execution of `gemini-cli` (which can be impure due to network access).
*   **Gemini Integration:** Takes `gemini-cli` as an input and wraps its execution with credential handling.
*   **Notes:** Designed to provide a secure and convenient way to run `gemini-cli` with `sops`-managed credentials.
*   **Feature Vector Mapping (from 10/07/plan.md):**
    *   1. Using Home Directory: **Yes** (sets up temporary `$HOME/.gemini/`)
    *   2. Using Telemetry: **No**
    *   3. Using OAuth Credentials: **Yes** (via `sops`-decrypted secrets)
    *   4. Using Nix Base: **Yes**
    *   5. Using a Makefile Target to Generate Input Text: **Yes** (the `ARGS` can be input text)
    *   6. Capturing all output files of the LLM from its working dir: **No** (the wrapper just executes `gemini-cli`)
    *   7. Using YOLO (You Only Live Once) Approval Model: **No**
    *   8. Capturing Telemetry: **No**
    *   9. With its Own Source Code as Input: **No**
    *   10. With Additional URLs or Targets as Hash Inputs: **No**
    *   11. Each Makefile Target is a Derivation: **Yes** (the `geminiCliWithSecrets` is a derivation)

---

This document will serve as a central reference for understanding the various Gemini-related Nix files and their impurity characteristics. It should help in identifying areas for refactoring, merging, or removing redundant tests.