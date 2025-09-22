# SOP: Gemini AI Context Primorial Knowledge Lattice Management

## 1. Purpose

This Standard Operating Procedure (SOP) outlines the guidelines and procedures for managing the "Gemini AI Context Primorial Knowledge Lattice" within the project's filesystem. The purpose is to ensure consistent, structured, and effective storage and retrieval of contextual information by Gemini, thereby enhancing its operational efficiency and knowledge retention.

## 2. Scope

This SOP applies to all project directories where `GEMINI.md` files are present or are intended to be created as part of the knowledge lattice. It also applies to the creation and maintenance of CRQ, SOP, and tutorial documents that contribute to this lattice.

## 3. Principles of the Knowledge Lattice

The knowledge lattice is built upon the following principles:
*   **Decentralized Context**: Contextual information is stored directly within relevant directories via `GEMINI.md` files, making it co-located with the code or documentation it describes.
*   **Hierarchical Organization**: The filesystem's directory structure naturally forms the hierarchy of the lattice, defining relationships between different pieces of knowledge.
*   **Primorial Elements**: Directories and core concepts (e.g., CRQ numbers, script names, module purposes) serve as fundamental building blocks and classifiers.
*   **Summarized Information**: `GEMINI.md` files should contain concise, high-value summaries and key takeaways relevant to their specific directory. Avoid redundancy; link to detailed documents (CRQs, SOPs, tutorials) where appropriate.
*   **Consistency**: Adhere to the defined structure and content guidelines for `GEMINI.md` files to ensure uniformity and ease of parsing by Gemini.

## 4. Procedure: Creating and Maintaining `GEMINI.md` Files

### 4.1. Identifying Relevant Directories

`GEMINI.md` files should be created in directories that:
*   Represent a significant functional area or module of the project.
*   Contain a collection of related files (e.g., `scripts/`, `docs/crqs/`, `vendor/nix/`).
*   Require specific contextual information for Gemini to operate effectively within that scope.

### 4.2. `GEMINI.md` Content Guidelines

Each `GEMINI.md` file should start with a level 2 heading: `## Gemini Added Memories for 
path/to/directory/
` (or `for 
./
` for the root directory).

Following this, include:
*   A brief, high-level description of the directory's purpose.
*   A "Key Information" section (using a level 2 heading `## Key Information:` or similar) with bullet points summarizing:
    *   The directory's role in major project initiatives (e.g., CRQ-016).
    *   Important files or subdirectories within it.
    *   Any specific instructions or considerations relevant to Gemini's interaction with this directory.
    *   Links to related CRQs, SOPs, or tutorials.

**Example Structure:**

```markdown
## Gemini Added Memories for `path/to/directory/`

This directory's purpose.

**Key Information:**
*   Point 1.
*   Point 2.
*   Link to [Related CRQ](path/to/crq.md).
```

### 4.3. Creating a New `GEMINI.md`

1.  **Navigate**: Change to the target directory where the `GEMINI.md` will reside.
2.  **Create File**: Create a new file named `GEMINI.md`.
3.  **Add Content**: Populate the file according to the content guidelines (Section 4.2).
4.  **Commit**: Add and commit the new `GEMINI.md` file to Git. Use a commit message like `docs(gemini): Add GEMINI.md for <directory_path>`.

### 4.4. Updating an Existing `GEMINI.md`

1.  **Navigate**: Change to the directory containing the `GEMINI.md` to be updated.
2.  **Edit File**: Modify the `GEMINI.md` file to reflect new information, changes in directory purpose, or updated instructions.
3.  **Commit**: Add and commit the updated `GEMINI.md` file to Git. Use a commit message like `docs(gemini): Update GEMINI.md for <directory_path>`.

## 5. Integration with Gemini's Workflow

Gemini is designed to automatically leverage the information within `GEMINI.md` files. When Gemini is operating within a directory or needs context about a specific path, it will prioritize reading the `GEMINI.md` file in that location and its parent directories to build its contextual understanding.

## 6. Troubleshooting

*   **Missing Context**: If Gemini seems to lack context about a specific area, check if a `GEMINI.md` file exists in that directory or its parent directories. If not, create one.
*   **Outdated Information**: Regularly review and update `GEMINI.md` files as the project evolves to ensure the information remains current.

## 7. Related Documents

*   [CRQ-016: Submodule Nixification and Flake Refactoring](docs/crqs/CRQ_016_Submodule_Nixification.md)
*   [Memo: Use Shellcheck Always After Changes](docs/memos/Shellcheck_Always_After_Changes.md)
*   CRQ-017: Formalizing Gemini AI Context as a Primorial Knowledge Lattice
*   [Contributing with CRQs and SOPs Tutorial](docs/tutorials/Contributing_with_CRQs_and_SOPs.md)
*   All CRQ documents in `docs/crqs/`
*   All SOP documents in `docs/sops/`
*   All tutorial documents in `docs/tutorials/`
