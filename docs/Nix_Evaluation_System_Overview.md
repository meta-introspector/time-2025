# Nix Evaluation System Overview

This document abstracts the problem of robustly evaluating arbitrary Nix expressions (files) and collecting structured errors when those evaluations fail or produce unexpected types. It outlines the key types and functions involved in the project's Nix evaluation and error handling system.

## Abstraction of the Problem

The core challenge is to safely and systematically process Nix expressions, ensuring that:
*   **Safe Evaluation**: All Nix expressions are evaluated in a way that prevents crashes, typically by using `builtins.tryEval`.
*   **Type Checking**: The results of evaluations conform to expected types (e.g., an attribute set for a `.nix` file that defines a package).
*   **Structured Error Reporting**: Any failures (syntax errors, evaluation errors, type mismatches) are captured and reported in a consistent, machine-readable format, including error type and a descriptive message.
*   **Error Aggregation**: Errors encountered during multiple evaluations (e.g., when scanning a directory of `.nix` files) are collected and presented as a comprehensive list.
*   **Circular Dependencies**: Interdependencies between Nix modules (e.g., a module that processes entries needing the main generation function, and vice-versa) are managed correctly to avoid infinite recursion or undefined variable errors.

## Key Types

1.  **`Path`**:
    *   **Description**: A Nix path value, representing a location in the file system.
    *   **Examples**: `./.`, `builtins.path { path = ./.; }`.

2.  **`EvalResult`**:
    *   **Description**: The structured output of `builtins.tryEval`.
    *   **Structure**: An attribute set `{ success = bool; value = any; error = string | null; }`.
        *   `success`: `true` if evaluation succeeded, `false` otherwise.
        *   `value`: The result of the evaluation if `success` is `true`. Can be any Nix value.
        *   `error`: A string containing the error message if `success` is `false`, otherwise `null`.

3.  **`ErrorEntry`**:
    *   **Description**: A structured attribute set representing a single, categorized error.
    *   **Structure**: `{ type = string; message = string; }`.
        *   `type`: A string categorizing the error (e.g., `"type_error"`, `"evaluation_error"`).
        *   `message`: A human-readable string describing the error.

4.  **`ErrorList`**:
    *   **Description**: A list containing zero or more `ErrorEntry`s.
    *   **Structure**: `[ ErrorEntry1, ErrorEntry2, ... ]`.

5.  **`ProcessedEntry`**:
    *   **Description**: The result of processing a single file system entry (e.g., a `.nix` file or a directory).
    *   **Structure**: An attribute set `{ value = any; errors = ErrorList; }`.
        *   `value`: The evaluated Nix value if successful and of the expected type, otherwise `null` or an empty attribute set.
        *   `errors`: A list of `ErrorEntry`s encountered during processing.

6.  **`Accumulator`**:
    *   **Description**: The state maintained and passed through the `lib.foldlAttrs` function in `fold-accumulator.nix`.
    *   **Structure**: An attribute set `{ result = AttrSet; errors = ErrorList; }`.
        *   `result`: An attribute set accumulating the successful `value`s from `ProcessedEntry`s.
        *   `errors`: A list accumulating all `ErrorEntry`s from `ProcessedEntry`s.

7.  **`GenerateResult`**:
    *   **Description**: The final output of the `generate.nix` function, representing the aggregated results and errors from scanning a directory.
    *   **Structure**: Identical to `Accumulator`: `{ result = AttrSet; errors = ErrorList; }`.

## Key Functions/Modules

1.  **`builtins.tryEval`**:
    *   **Location**: Built-in Nix function.
    *   **Input**: A Nix expression.
    *   **Output**: `EvalResult`.
    *   **Purpose**: Safely evaluates a given Nix expression, catching any evaluation errors and returning a structured `EvalResult`.

2.  **`error-constructor.nix`**:
    *   **Location**: `lib/generate-project-nix/error-constructor.nix`
    *   **Purpose**: Provides functions to construct standardized `ErrorEntry`s.
    *   **Functions**:
        *   **`typeError`**:
            *   **Input**: `expectedType: string`, `actualType: string`.
            *   **Output**: An attribute set `{ value = {}; errors = ErrorList; }` where `ErrorList` contains a single `ErrorEntry` of `type = "type_error"`.
            *   **Purpose**: Creates a structured error for cases where an evaluated value does not match an expected type.
        *   **`evaluationError`**:
            *   **Input**: `errorMessage: string`.
            *   **Output**: An attribute set `{ value = {}; errors = ErrorList; }` where `ErrorList` contains a single `ErrorEntry` of `type = "evaluation_error"`.
            *   **Purpose**: Creates a structured error for general Nix evaluation failures.

3.  **`error-isolation.nix`**:
    *   **Location**: `lib/generate-project-nix/error-isolation.nix`
    *   **Input**: `{ evalResult: EvalResult; file: Path; builtins; errors; types; }`.
    *   **Output**: `ProcessedEntry`.
    *   **Purpose**: Analyzes an `EvalResult`. If successful, it checks if the `value` is an attribute set. If not, or if `evalResult.success` is `false`, it uses `error-constructor.nix` to generate appropriate `ErrorEntry`s and returns a `ProcessedEntry` with `value = null` and the collected errors.

4.  **`wrapEval.nix`**:
    *   **Location**: `lib/generate-project-nix/wrapEval.nix`
    *   **Input**: `{ file: Path; builtins; }`.
    *   **Output**: `EvalResult`.
    *   **Purpose**: A thin wrapper around `builtins.tryEval (import file)`, providing a consistent interface for evaluating Nix files.

5.  **`evaluateNixFile.nix`**:
    *   **Location**: `lib/generate-project-nix/evaluateNixFile.nix`
    *   **Input**: `{ file: Path; pkgs; lib; builtins; tryEval; types; errors; }`.
    *   **Output**: `ProcessedEntry`.
    *   **Purpose**: The primary function for evaluating a single Nix file. It uses `wrapEval.nix` for safe evaluation and then passes the `EvalResult` to `error-isolation.nix` for structured error handling and type checking.

6.  **`processEntry.nix`**:
    *   **Location**: `lib/generate-project-nix/processEntry.nix`
    *   **Input (module arguments)**: `{ lib; generate; evaluateNixFile; errors; types; builtins; }`.
    *   **Input (function call)**: `path: Path`, `name: string`, `type: string` (from `builtins.readDir`).
    *   **Output**: `ProcessedEntry`.
    *   **Purpose**: Acts as a dispatcher for file system entries. It decides whether to:
        *   Recursively call `generate` if the entry is a directory.
        *   Call `evaluateNixFile` if the entry is a `.nix` file.
        *   Return an empty `ProcessedEntry` (with no value and no errors) for other file types.

7.  **`fold-accumulator.nix`**:
    *   **Location**: `lib/generate-project-nix/fold-accumulator.nix`
    *   **Input (module arguments)**: `{ lib; types; }`.
    *   **Input (function call)**: `acc: Accumulator`, `name: string`, `entry: ProcessedEntry`.
    *   **Output**: `Accumulator`.
    *   **Purpose**: An accumulator function designed for `lib.foldlAttrs`. It merges the `value` from a `ProcessedEntry` into the `acc.result` attribute set (if the value is an attribute set) and concatenates the `errors` from the `ProcessedEntry` into `acc.errors`.

8.  **`generate.nix`**:
    *   **Location**: `lib/generate-project-nix/generate.nix`
    *   **Input (module arguments)**: `{ lib; builtins; processEntry; evaluateNixFile; errors; types; }`.
    *   **Input (function call)**: `path: Path`.
    *   **Output**: `GenerateResult`.
    *   **Purpose**: The main recursive function that orchestrates the scanning and evaluation of a directory tree. It reads directory entries using `builtins.readDir`, processes each entry using `processEntry`, and then aggregates all results and errors using `lib.foldlAttrs` with `fold-accumulator.nix`.
