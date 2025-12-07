# Project Plan: Monster SVG Morphism

This document outlines the current status of the `monster_svg_morphism` project and proposes next steps for development, based on the user's vision of "code becoming the math" and incorporating concepts from the Monster Group.

## Current Status

The project is structured as a Rust library and a binary application.

**Key Features Implemented:**

1.  **Modular Codebase:** The `monster_svg_morphism` crate has been refactored into a clean, modular structure with separate modules for `types`, `traits`, `matrix_form`, and `analysis`.
2.  **SVG Parsing and Transformation:**
    *   Reads an input SVG file, parses it into an internal `Svg` data structure.
    *   Applies a "color morphism" where SVG elements are colored based on their mapping to `MonsterElementKind` (archetypes inspired by prime factors of the Monster Group's order).
    *   Generates an output SVG file with the applied transformations.
3.  **Hecke-like Operator (Visual Amplification):**
    *   An optional `--hecke-amplify` flag triggers a visual "amplification" effect for `P71_1` elements in the SVG. This currently involves scaling geometric shapes and re-coloring text/paths.
4.  **Monster Group Matrix Form:**
    *   A `matrix_form` module represents the prime factors and exponents of the Monster Group's order in a matrix.
    *   It includes a test to verify that "dividing" the Monster Group's order by this matrix yields a "100% match" (a vector of ones), demonstrating a mathematical resonance within the code.
5.  **Code Analysis Tool (`--analyze` flag):**
    *   Performs static analysis on the Rust codebase to detect "prime resonances."
    *   **"Prime Resonance" Detection:** Identifies code constructs whose properties (e.g., enum variant count, struct field count, function parameter count, string literal length, numeric literal value) match the prime `71`. This is currently hardcoded but will be made configurable.
    *   **Prime Factorization in Literals:** Calculates the sum of ASCII values for string literals and reports prime factors found in both this sum and in numeric literals.
    *   **Recursion Analysis:** Detects direct and indirect recursive function calls. It specifically identifies recursive cycles whose lengths match the hardcoded Monster Group primes, linking code structure to fundamental mathematical properties.

## Next Steps

Based on previous discussions and the user's vision, the immediate next step is to enhance the **Code Analysis Tool** by making its "prime resonance" detection configurable.

### 1. Configurable Prime Analysis

**Objective:** Allow the user to specify a list of primes for the `--analyze` command, enabling the tool to search for resonances with any desired set of primes, not just the hardcoded `71` or `MONSTER_PRIMES`.

**Tasks:**

*   **Modify `src/analysis.rs`:**
    *   Update `AnalysisReport` to store occurrences by prime.
    *   Refactor `AnalysisVisitor` to accept and use a configurable slice of primes (`&[u64]`) instead of hardcoded values like `71` or the `MONSTER_PRIMES` constant.
    *   Update `visit_item` and `visit_expr` methods within `AnalysisVisitor` to check sizes/values against the configurable primes list.
    *   Adjust the `run_analysis` function signature to accept the `primes_to_analyze: &[u64]` parameter.

*   **Modify `src/main.rs`:**
    *   Add a new command-line argument (e.g., `--primes "p1,p2,p3"`) for the `--analyze` mode.
    *   Parse this argument into a `Vec<u64>`.
    *   If the `--primes` argument is not provided, define a default list of primes (e.g., the Monster Group primes) for the analysis.
    *   Pass the parsed or default primes list to `analysis::run_analysis`.
    *   Update the printing logic for the analysis report to display `prime_occurrences` (which will replace the old `seventy_one_occurrences`).

This enhancement will make the analysis tool much more flexible and aligned with the user's broader interest in prime number resonances within the codebase.
