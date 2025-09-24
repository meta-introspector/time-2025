# CRQ-033: Knowledge as Flakes: Compiling Wikipedia into Searchable Nix Attributes for AI Context Composition

## 1. Goal

The primary goal is to establish a "Nix Flake of Knowledge" system. This system will process unstructured information, starting with Wikipedia articles, and compile it into a structured, searchable format within the Nix ecosystem. The ultimate aim is to create composable AI contexts from this knowledge base.

## 2. Problem Statement

Currently, leveraging large, unstructured datasets like Wikipedia for AI model context is ad-hoc and not easily reproducible. There is no standardized way to version, search, and compose this knowledge. This leads to inconsistent results and difficulty in managing the data provenance for AI training and context generation.

## 3. Proposed Solution

We propose a system that:

1.  Fetches and caches external knowledge sources (e.g., Wikipedia articles).
2.  Processes these sources to extract meaningful data.
3.  Packages the processed data into NAR (Nix Archive) files, ensuring immutability and content-addressing.
4.  Creates a top-level Nix flake that exposes this data through a searchable, structured attribute set. For example, `knowledge.wikipedia.articles.<article-name>.text` or `knowledge.wikipedia.articles.<article-name>.metadata`.
5.  These "knowledge flakes" can then be used as inputs for other flakes, allowing for the composition of complex, version-controlled AI contexts.

## 4. Scope

*   **In-Scope:**
    *   Developing scripts to fetch and process Wikipedia articles.
    *   Creating a Nix flake structure to represent the knowledge.
    *   Storing article content as NAR payloads.
    *   Defining a searchable attribute set based on article titles and metadata.
*   **Out-of-Scope:**
    *   The implementation of the AI models themselves.
    *   Advanced NLP processing (e.g., entity extraction, sentiment analysis) in the initial phase.
    *   A generalized framework for any arbitrary knowledge source (the focus is on Wikipedia first).

## 5. Technical Details

The implementation will involve:

*   A shell script or Nix derivation to handle the fetching of Wikipedia articles.
*   A processing script (e.g., using `jq`, `sed`, `awk`, or a more robust language like Python) to clean the HTML/text and extract basic metadata.
*   Using `nix-store --add` or similar mechanisms to package the cleaned text into NAR files.
*   A `flake.nix` that reads a manifest of processed articles and generates a deeply nested attribute set where paths correspond to article topics and final attributes point to the NAR store paths.

## 6. Verification

Success will be verified by:

*   Successfully building the knowledge flake (`nix build .#knowledge.wikipedia`).
*   Inspecting the resulting attribute set using `nix repl` to confirm it's structured as designed.
*   Querying the path of a specific article attribute and verifying that it points to a valid store path containing the correct NAR-packaged content.
