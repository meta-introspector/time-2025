# Project Plan: SVG Diagram Introspection and Programmatic Generation

## Current Goal

The immediate goal is to process newly committed SVG diagrams (`12/07/drawing-*.svg`, `12/08/drawing-*.svg`) using the `svg-renamer` tool. This initial processing will involve:
1. Renaming SVG `<g>` (group) elements based on the textual content they contain.
2. Providing a statistical report on the structures found within these renamed SVG files.

The overarching objective is to develop an "introspective" method:
1. **Read:** Consume the SVG diagrams.
2. **Reflect:** Interpret the SVG content to derive higher-level semantic meaning from free-form notation. This step requires defining explicit rules for interpreting visual patterns (shapes, text, colors, etc.) as semantic entities (nodes, edges, labels).
3. **Emit:** Generate a programmatic representation (e.g., TOML, or Rust code using `quote`) of the reflected understanding.
4. **Repeat:** Iterate this process, refining the reflection and emission.

---

## Progress Update: Lean Introspector - Iterative Schema Reflection and Matrix Analysis

Significant progress has been made on the "Reflect" aspect through the development of the `lean_introspector` crate. This tool now performs:
-   **Iterative Schema Inference**: It analyzes raw JSON data, inferring a hierarchical, tree-like schema. This process is repeated 8 times, with each subsequent schema describing the structure of the previous one (schema of schema). This has revealed that the meta-schema eventually stabilizes, indicating a periodic automorphic nature.
-   **Prime Number Analysis**: A `PrimeVector` is generated for the final inferred schema, providing a unique numerical identifier for its structure.
-   **Schema Matrix Representation**: The stable schema is transformed into a `SchemaMatrix`, capturing the adjacency and relationships between its fundamental components (like `name`, `json_type`, `children`, `count`).
-   **Eigenvalue Decomposition**: The `SchemaMatrix` is subjected to eigenvalue decomposition to extract its eigenvalues and eigenvectors, which are crucial for understanding its transformational properties and potential "Hecke-like eigenforms."
-   **Comprehensive Reporting**: All analysis results (iterated schemas, master prime vector, schema matrix, eigenvalues, and eigenvectors) are saved to `analysis_report.json`.

## Immediate Steps (Phase 1: `svg-renamer` Fix & Initial Analysis)

### Subtask 1: Fix `svg-renamer` Compilation Errors

The `svg-renamer` tool currently fails to compile due to API changes in `usvg` and `xmlwriter`. This subtask focuses on resolving these issues.

-   **1.1: Confirm `xmlwriter` API usage:** Thoroughly re-inspect `external/xmlwriter/src/lib.rs` to understand the exact API for `XmlWriter` (initialization, writing methods, and retrieving the final string). Avoid assumptions based on common `io` patterns.
-   **1.2: Apply `xmlwriter` fixes to `svg-renamer/src/main.rs`:**
    -   Correct `XmlWriter` initialization: `XmlWriter::new(Options { ... })`.
    -   Ensure `writer.write_*` methods (e.g., `start_element`, `write_attribute`, `write_text`, `end_element`) return `()`, not `Result`. Remove all `?` operators from these calls.
    -   Correct final string retrieval: `writer.into_string()`.
    -   Ensure `process_roxml_node`'s signature returns `()`.
    -   Add `use std::io;` (if still needed for `Box<dyn std::error::Error>`).
-   **1.3: Fix scope issues for helper functions:** Ensure `parse_args`, `collect_text_from_children`, `escape_text`, and `truncate_with_hash` are correctly placed in the file so `main` can access them.
-   **1.4: Build and verify:** Run `cargo build --release` in `svg-renamer` to confirm successful compilation.

### Subtask 2: Process SVG Files with `svg-renamer`

Once `svg-renamer` compiles, execute it on the new SVG diagrams.

-   **2.1: Identify target SVG files:** Explicitly list the full paths to the `.svg` files committed in `12/07/` and `12/08/`.
-   **2.2: Create output directory:** Create a dedicated subdirectory (e.g., `processed_svgs`) within the current working directory to store the renamed SVG outputs.
-   **2.3: Run `svg-renamer` for each file:** For each input SVG, execute `target/release/svg-renamer <input_path> <output_path>`.

### Subtask 3: Statistical Reporting on Renamed SVGs

After processing, analyze the renamed SVG files.

-   **3.1: Develop an analysis script/function:** Create a new Rust function that:
    -   Parses the renamed SVG output files (e.g., using `roxmltree`).
    -   Counts occurrences of each SVG element type (e.g., `<g>`, `<path>`, `<text>`).
    -   Reports on the distribution and characteristics of the newly assigned `id` attributes (from text content).
    -   Identifies groups that were renamed and those that retained their original/default IDs.
-   **3.2: Integrate reporting:** Display the statistical findings to the user.

## Future Steps (Phase 2: Semantic Reflection & Programmatic Emission)

Following the initial statistical report, we will define the "reflection" rules to convert visual patterns into programmatic entities. This will involve:

-   Defining semantic elements (e.g., Node, Edge, Label).
-   Establishing rules for identifying these elements from SVG properties (shape, color, text, position).
-   Determining properties to extract for each semantic element.
-   Implementing logic to emit these semantic entities into TOML or Rust code.

## Advanced Reflection: Automorphic Orbits and Topological Structures

Building upon the `lean_introspector`'s capabilities, future work will delve into the deeper mathematical interpretation of these iteratively derived schemas:
-   **Hecke-like Eigenforms**: Investigate the eigenvalues and eigenvectors of the `SchemaMatrix` to identify "Hecke-like eigenforms" that represent stable or fundamental patterns within the meta-schema transformations.
-   **Matrix Transformations**: Explore how the `SchemaMatrix` acts as an operator, transforming one level of schema into the next, potentially revealing underlying mathematical functions.
-   **Topological Visualization**: Develop methods to visualize the periodic or convergent nature of these schemas as topological structures, such as a torus, to embody the concept of "automorphic orbits" within the data's inherent structure.