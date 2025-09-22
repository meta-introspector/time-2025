# SOP: Emacs Org Mode Integration for Gemini CLI Implementation

## Purpose:
This Standard Operating Procedure (SOP) outlines the guidelines and best practices for integrating `gemini-cli` interaction within Emacs Org mode, enabling users to define, execute, and capture `gemini-cli` tasks directly from their Org documents.

## Scope:
This SOP applies to the development of Emacs Lisp functions and Org mode configurations necessary to facilitate `gemini-cli` interaction within Org mode.

## Procedure:

### 1. Exploring Integration Methods:

1.  **Org Babel Source Blocks**: The primary method for integrating external processes in Org mode is through Org Babel. This involves defining a new Babel language or extending an existing one (e.g., `sh` or `emacs-lisp`) to handle `gemini-cli` calls.

    -   **Approach**: Define a custom Babel language header (e.g., `#+BEGIN_SRC gemini-cli ... #+END_SRC`) that takes the block content as the prompt and executes `gemini-cli`.
    -   **Parameters**: Consider how to pass `gemini-cli` parameters (e.g., model, include directories) via Babel header arguments.

2.  **Custom Org Mode Functions**: Develop Emacs Lisp functions that operate on specific Org mode structures (e.g., headings, properties, custom blocks) to trigger `gemini-cli` execution.

    -   **Approach**: A function could, for instance, take the content of an Org subtree as a prompt, run `gemini-cli`, and insert the output as a new subtree or property.

### 2. Defining Prompt and Context:

1.  **Prompt Content**: The content of the Org Babel source block or the selected Org region will serve as the main prompt for `gemini-cli`.

2.  **Prelude and Context**: Determine how to incorporate the `prelude.md` content and other contextual information (e.g., file contents, project structure) into the `gemini-cli` call from within Org mode.

    -   **Options**: Babel header arguments, Org properties, or a dedicated Emacs Lisp function to dynamically gather context.

### 3. Capturing and Displaying Output:

1.  **Output Insertion**: `gemini-cli` output should be captured and inserted back into the Org document.

    -   **Org Babel**: Output can be automatically inserted into a `#+RESULTS:` block following the source block.
    -   **Custom Functions**: Output could be inserted as a new Org block, a property, or appended to an existing section.

2.  **Error Handling**: Implement robust error handling to display `gemini-cli` errors clearly within the Org document or Emacs messages.

### 4. Workflow Considerations:

1.  **Task Management**: How can Org mode's task management features (TODO states, scheduling) be leveraged for `gemini-cli` tasks?

2.  **Literate Programming**: Encourage the use of Org mode for literate programming, where `gemini-cli` prompts and their results are part of a narrative document.

### 5. Technical Implementation Details:

1.  **Emacs Lisp**: All integration logic will be written in Emacs Lisp.
2.  **Org Mode API**: Utilize Org mode's extensive Emacs Lisp API for parsing, manipulating, and inserting content into Org buffers.
3.  **Asynchronous Execution**: Ensure `gemini-cli` calls are asynchronous to prevent Emacs from freezing.

## 6. Testing and Verification:
- Create sample Org mode files with `gemini-cli` prompts.
- Verify that prompts execute correctly and output is captured as expected.
- Test various scenarios, including error conditions and different `gemini-cli` parameters.

## Related Documents:
- [CRQ-016: Submodule Nixification and Flake Refactoring](docs/crqs/CRQ_016_Submodule_Nixification.md)
- [Memo: Use Shellcheck Always After Changes](docs/memos/Shellcheck_Always_After_Changes.md)
- [Contributing with CRQs and SOPs Tutorial](docs/tutorials/Contributing_with_CRQs_and_SOPs.md)
- `docs/crqs/CRQ_Emacs_Org_Mode_Integration_for_Gemini_CLI.md`
- `solfunmeme-gemini.el`
- Org Mode Manual

## Revision History:
- [Date]: Initial Draft
