# CRQ-034: Automated Domain-Specific Knowledge Graph Generation for LLM Context

## 1. Goal

To automatically discover URLs within the project's scope, aggregate knowledge by top-level domain into size-constrained, LLM-optimized Nix Archive (NAR) files, and organize this knowledge hierarchically for efficient AI context composition.

## 2. Problem Statement

As the project grows, manually curating and optimizing knowledge for LLM consumption becomes unscalable. There's a need for an automated system to extract, structure, and cache domain-specific information from various sources (starting with URLs) into a format suitable for LLMs, while respecting context window limitations and enabling granular access to sub-aspects of knowledge.

## 3. Proposed Solution

1.  **URL Discovery:** Develop a mechanism to identify URLs from various project sources (e.g., parsing `flake.nix` inputs, `README.md` files, or a dedicated manifest).
2.  **Knowledge Extraction & Optimization:** Implement a pipeline to fetch URL content, extract relevant text, and pre-process it for LLM consumption (e.g., summarization, cleaning, keyword identification), ensuring it fits within defined size limits.
3.  **Nix Flake Structure:** Design a Nix flake structure that dynamically groups knowledge by Top-Level Domain (TLD). Each TLD will have a root NAR file (within size limits) and potentially nested NAR files for sub-aspects or specific paths within that domain.
4.  **Custom Attributes:** Utilize custom attributes within Nix derivations to store rich metadata about each knowledge segment (e.g., source URL, summary, keywords, size, last updated timestamp).
5.  **Publishing Integration:** Integrate with the `crq-binstore` for automated publishing and versioning of these domain-specific knowledge NARs.

## 4. Scope

*   **In-Scope:**
    *   URL discovery from specified project files/manifests.
    *   Text extraction and basic summarization/cleaning of web content.
    *   NAR generation with configurable size constraints.
    *   Hierarchical organization of knowledge by TLD and sub-paths within the Nix flake.
    *   Custom attribute definition for metadata (source URL, summary, keywords, etc.).
    *   Integration with `crq-binstore` for automated publishing.
*   **Out-of-Scope (for initial phase):**
    *   Advanced Natural Language Processing (NLP) tasks (e.g., entity linking, complex reasoning, sentiment analysis).
    *   Real-time web crawling or continuous monitoring of external sources.
    *   Handling of non-textual content beyond basic extraction (e.g., images, videos).
    *   Dynamic adaptation to LLM context window changes (initial focus on static, configurable size limits).

## 5. Technical Details

*   **URL Discovery:** A script (e.g., Python or Bash with `grep`/`awk`) to parse relevant project files (e.g., `flake.nix`, `README.md`, `docs/`) for URLs. A dedicated `urls.json` manifest could also be introduced.
*   **Knowledge Extraction & Pre-processing:** A Python script leveraging libraries like `requests` for fetching and `BeautifulSoup` or `lxml` for HTML parsing and text extraction. This script will also handle summarization and chunking to meet size limits.
*   **Nix Structure:** A `flake.nix` that dynamically generates derivations. This will involve Nix built-ins like `builtins.readDir`, `builtins.fromJSON`, and `pkgs.lib.mapAttrs` to create a nested attribute set representing the domain knowledge graph. Each leaf attribute will be a derivation packaging a NAR file.
*   **Size Management:** Logic within the Python pre-processing script to split content into multiple NARs or summarize if a single domain's knowledge exceeds a defined byte/token limit.
*   **Publishing:** Adaptation of the `publish_knowledge_node_nar.sh` script (or a new generalized version) to iterate through the generated domain knowledge derivations and publish their NARs to `crq-binstore`.

## 6. Verification

*   Successful discovery and listing of URLs from test sources.
*   Generation of TLD-specific and sub-path NAR files with correct content and metadata.
*   Verification that all generated NAR file sizes adhere to specified limits.
*   Successful automated publishing of generated NARs to `crq-binstore`.
*   Ability to query and inspect the hierarchical knowledge structure using `nix repl` and `nix-nar-unpack` to confirm data integrity and accessibility.
