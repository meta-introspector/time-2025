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

## Monster Map Project: Comprehensive SVG Element Analysis

**Overarching Vision:** To interpret SVG diagrams as a "self-symmetric, self-creating program" with its own embedded language, for which we are building an interpreter in Rust. The goal is to establish a "Monster Map" that quantifies "how much Monster symmetry" each SVG element possesses, by correlating linguistic, structural, and content-based properties with the prime factorization of the Monster group's order. This will serve as a foundational analysis for a DAO (Decentralized Autonomous Organization) composed of humans and LLMs.

---

### Phase 1: Foundational Data Generation

**Subtask 1.1: Generate Semantic Dictionary Template (`wikivector`)**
- **Objective:** Extract all unique text snippets from an SVG to create a template for a domain-specific semantic dictionary. This dictionary will be filled by humans and LLMs in a DAO.
- **Status:** **COMPLETED.** The `wikivector` tool has successfully generated `output/semantic_dictionary_template.toml`.

**Subtask 1.2: Perform N-gram Linguistic Analysis (`ngram-analyzer`)**
- **Objective:** Analyze the linguistic patterns (emoji and word n-grams) within the SVG's text content, rank them by frequency, and map the top 108 n-grams to the prime factors of the Monster group's order (with exponents as weights). This provides a "linguistic profile" for the Monster Map.
- **Status:** **COMPLETED.** The `ngram-analyzer` tool has generated `output/ngram_report.json`, including the ranked n-grams, Monster prime mapping, and the "Monster Backpack Filling Score".

---

### Phase 2: Structural and Content-Based Element Analysis (`bsp-buddy-finder`)

**Overarching Objective:** Enhance the `bsp-buddy-finder` tool to perform a multi-faceted "buddy" analysis, contributing to the "Structural Profile" and "Content & Shape Profile" of the Monster Map.

**Immediate Priority: Fix `bsp-buddy-finder` Compilation Errors**
- **Problem:** The `bsp-buddy-finder` tool currently fails to compile due to incorrect `usvg` API usage and `svg_hir` element construction.
- **Action:** Resolve all reported compilation errors in `bsp-buddy-finder/src/main.rs`.

**Subtask 2.1: Implement Creation Order Buddies**
- **Objective:** For each SVG element, identify its "buddy" as the element immediately preceding it in a list sorted by original numeric ID (creation order).
- **Details:** This will involve parsing the SVG, extracting elements with IDs, sorting them numerically, and identifying sequential pairs.

**Subtask 2.2: Implement Containment Buddies**
- **Objective:** For each SVG element, identify its "buddies" as other elements contained within the same parent `<g>` (group) element.
- **Details:** This will require traversing the SVG's hierarchical structure and mapping parent-child relationships.

**Subtask 2.3: Implement Spatial Proximity Buddies (using BSP Tree)**
- **Objective:** For each SVG element, identify its "buddy" as the closest element in terms of geometric distance, utilizing the existing BSP tree implementation in `svg_hir`.
- **Details:** This involves correctly constructing the BSP tree from element bounding boxes and implementing an efficient nearest-neighbor search with a combined metric (geometric distance + ID difference).

**Subtask 2.4: Implement Connectivity Buddies (Future)**
- **Objective:** For each SVG element, identify "buddies" that are physically connected by lines or paths.
- **Details:** This is a complex task requiring analysis of path data and will be addressed in a later iteration.

**Subtask 2.5: Implement Content & Shape Similarity Buddies (Future)**
- **Objective:** For each SVG element, identify "buddies" with similar shapes and compositions.
- **Details:** This involves generating "content fingerprints" (e.g., dimension comparisons for simple shapes, style comparisons) and will be phased, starting with simpler attribute-based similarity and deferring complex path comparison. This will also contribute to a "shape prime" mapping.

**Subtask 2.6: Generate Comprehensive JSON Report**
- **Objective:** Output a single JSON report that, for each element, lists all identified buddies (creation order, spatial, containment, connectivity, similarity).

---

### Phase 3: Monster Map Report & Score Generation (Future)

**Overarching Objective:** Integrate all profiles (linguistic, structural, content/shape) into a unified "Monster Map Report" and calculate a comprehensive "Monster Symmetry Score" for each element.

- **Details:** This will involve combining data from `ngram_report.json` and the `bsp-buddy-finder` output, potentially mapping content/shape fingerprints to Monster primes, and developing a holistic scoring mechanism.
- **Visualization:** Develop an SVG visualization tool to represent the "Monster Map" as a tree or graph, incorporating the 15 layers and prime mappings.