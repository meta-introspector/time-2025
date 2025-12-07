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
    *   **"Prime Resonance" Detection:** Identifies code constructs whose properties (e.g., enum variant count, struct field count, function parameter count, string literal length, numeric literal value) match configurable primes.
    *   **Configurable Prime Analysis:** Allows the user to specify a list of primes for the `--analyze` command, enabling the tool to search for resonances with any desired set of primes.
    *   **Embedded Prime Detection:** Identifies prime numbers (both `u64` and large numbers comparable as strings, like the Monster Group order) embedded as digit sequences within string literals.
    *   **Prime Factorization in Literals:** Calculates the sum of ASCII values for string literals and reports prime factors found in both this sum and in numeric literals.
    *   **Recursion Analysis:** Detects direct and indirect recursive function calls. It specifically identifies recursive cycles whose lengths match the configured primes.
    *   **Self-Path Generation:** Generates a unique, shortest path from the crate root to each significant declaration (modules, functions, structs, enums, constants). This path provides context for each analyzed element.

## Next Steps

The overarching vision is to treat the program as a "tapestry of matrices" by embedding its structure and properties into mathematical forms. The immediate next steps build upon the self-path generation and prime vector embedding.

### 1. Program as a Matrix of Primes

**Objective:** Represent the entire program, or significant parts of it, as a matrix derived from its prime vector embeddings.

**Tasks:**

*   **Refine Prime-Coefficient Vector Embedding:**
    *   Complete the implementation of mapping AST self-paths (`Vec<String>`) into `PrimeVector`s (prime-coefficient vectors).
    *   Ensure coefficients accurately reflect path depth, component type, or other meaningful structural properties.
    *   Store these `PrimeVector`s in a `symbol_table` within the `AnalysisReport`, mapping the full string path to its `PrimeVector`.

### 2. Matrix Self-Multiplication (Conceptual Exploration)

**Objective:** Explore the implications and results of multiplying the "program matrix" by itself.

**Tasks:**

*   **Define "Program Matrix":** Determine how to construct a meaningful matrix from the collection of `PrimeVector`s in the `symbol_table`. This might involve:
    *   Ordering elements based on their paths.
    *   Selecting a subset of primes for the matrix dimensions.
    *   Converting sparse `PrimeVector`s into rows/columns of the matrix.
*   **Implement Matrix Multiplication (Conceptual/Simplified):**
    *   For the initial exploration, this might not involve full-blown matrix algebra on a giant matrix.
    *   Instead, focus on the *conceptual result*: what does multiplying a "program matrix" by itself signify in terms of program properties, connections, or emerging patterns?
    *   This could involve operations on the `PrimeVector`s themselves (e.g., combining vectors of related nodes, or applying a transformation based on the structure).
    *   Consider what "self-multiplication" of the program implies for its mathematical representation. Does it reveal symmetries, emergent properties, or deeper structural resonances?

### 3. Enhanced Reporting

**Objective:** Update the analysis report to present the newly generated `PrimeVector`s and any initial conceptual results from the matrix operations.

**Tasks:**

*   **Display Symbol Table:** Clearly present the `symbol_table` (full path -> `PrimeVector`) in the analysis report.
*   **Report Matrix Multiplication Insights:** If conceptual multiplications are explored, report any derived insights or patterns.

These steps will deepen the mathematical embedding of the codebase and open avenues for exploring its "algebraic" properties.