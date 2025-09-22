# CRQ-017: Formalizing Gemini AI Context as a Primorial Knowledge Lattice

## 1. Overview

This Change Request (CRQ) proposes the formalization and systematic construction of Gemini's operational context as a "Primorial Knowledge Lattice" within the project's filesystem. The objective is to enhance Gemini's ability to store, retrieve, and utilize contextual information efficiently, thereby improving its performance, consistency, and adherence to project conventions. This initiative aims to transform the implicit context management into an explicit, structured, and navigable knowledge base.

## 2. Problem Statement

Currently, Gemini's contextual understanding relies on a combination of:
*   Ephemeral session memory.
*   Ad-hoc file reads and searches.
*   User-provided "memories" (via `save_memory`).
*   Implicit understanding of project structure and conventions.

This approach, while functional, presents several limitations:
*   **Context Volatility**: Session-specific context is lost, requiring re-discovery.
*   **Inefficient Retrieval**: Locating relevant information can be time-consuming and resource-intensive.
*   **Inconsistent Application**: Reliance on implicit understanding can lead to deviations from project conventions.
*   **Limited Scalability**: As the project grows, maintaining comprehensive context becomes increasingly challenging.
*   **Lack of Transparency**: The internal workings of context management are opaque, hindering debugging and improvement.

## 3. Proposed Solution: The Primorial Knowledge Lattice

The solution is to explicitly construct and maintain a "Primorial Knowledge Lattice" within the project's filesystem. This lattice will be characterized by:

*   **Nodes**: Key contextual elements, primarily `GEMINI.md` files, CRQ documents, SOPs, and tutorials, strategically placed within the directory structure. These nodes will contain summarized, high-value information relevant to their respective locations.
*   **Edges (Relationships)**: The hierarchical structure of the filesystem itself will define the relationships between nodes. Directories represent logical groupings, and file paths represent paths through the knowledge lattice.
*   **Primorial Elements**: Directories and fundamental concepts (e.g., CRQ numbers, script names, core project components) will serve as "primorial" elements, acting as anchors and classifiers within the lattice.
*   **Standardized Content**: `GEMINI.md` files will follow a consistent format, providing "Gemini Added Memories" specific to their directory's purpose and contents.

### Implementation Strategy:
1.  **`GEMINI.md` Standardization**: Define a clear structure and content guidelines for `GEMINI.md` files.
2.  **Progressive Population**: Incrementally populate `GEMINI.md` files in relevant directories, starting with high-impact areas.
3.  **Automated Maintenance (Future)**: Explore tools or scripts to assist in generating and updating `GEMINI.md` content based on project changes.
4.  **Integration with Gemini's Logic**: Modify Gemini's internal logic to prioritize reading and leveraging information from this knowledge lattice for context.

## 4. Scope

### In-Scope:
*   Definition of the "Primorial Knowledge Lattice" concept and its components.
*   Creation of `GEMINI.md` files in key project directories (e.g., root, `scripts/`, `docs/`, `vendor/nix/`).
*   Populating `GEMINI.md` files with concise, high-value contextual information relevant to their location.
*   Documenting the purpose and structure of this knowledge lattice.

### Out-of-Scope:
*   Automated generation or real-time synchronization of `GEMINI.md` content (this may be a future enhancement).
*   Changes to Gemini's core AI architecture beyond context retrieval mechanisms.
*   Comprehensive indexing of *all* project files into the lattice (focus on key contextual elements).

## 5. Technical Details

### Files Created/Modified:
*   `docs/crqs/CRQ_017_Gemini_AI_Context_Lattice.md` (new)
*   `docs/sops/SOP_Gemini_AI_Context_Lattice.md` (new)
*   `docs/tutorials/Tutorial_Gemini_AI_Context_Lattice.md` (new)
*   Various `GEMINI.md` files across the project directories.

### Key Changes:
*   **Explicit Context**: Transition from implicit to explicit context management through structured `GEMINI.md` files.
*   **Hierarchical Knowledge**: Leveraging the filesystem hierarchy to organize and relate contextual information.
*   **Enhanced Retrieval**: Providing Gemini with direct, structured access to relevant project context.

## 6. Testing

Testing will involve:
*   **Manual Inspection**: Verifying the presence, content, and accuracy of `GEMINI.md` files.
*   **Gemini Interaction**: Observing Gemini's ability to leverage the new contextual information in its responses and actions.
*   **Consistency Checks**: Ensuring `GEMINI.md` files adhere to the defined structure and content guidelines.

## 7. Rollback Plan

In case of issues, the following rollback steps can be taken:
1.  **Revert commits**: Use `git revert <commit-hash>` for the commits related to this CRQ. This will remove the newly created `GEMINI.md` files and the CRQ/SOP/Tutorial documents.

## 8. Future Considerations

*   Develop automated tools for generating and updating `GEMINI.md` content.
*   Integrate the knowledge lattice with Gemini's internal memory and reasoning processes more deeply.
*   Explore visualization tools for the knowledge lattice.

## 9. Approval

[ ] Approved by: [Name]
[ ] Date: [Date]
