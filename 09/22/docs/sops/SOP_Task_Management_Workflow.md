# SOP: Task Management Workflow

## Purpose:
This Standard Operating Procedure (SOP) defines the workflow for managing development tasks, from identification to documentation of completion. It aims to ensure consistency, transparency, and accurate reporting of project progress.

## Scope:
This SOP applies to all development tasks within the project, particularly those involving the `gemini-cli` and its associated prompt files.

## Procedure:

### 1. Task Identification and Assignment:
- Tasks are identified through various means (e.g., project planning, user requests, bug reports).
- Each task should ideally be represented by a markdown file (e.g., `prompts/task_XXX.md`) in the `prompts/` directory.

### 2. Task Execution:
- Developers work on assigned tasks.
- During execution, `gemini-cli` may be used to generate outputs (e.g., `.out1.md` files) associated with the task.

### 3. Identifying Task Completion:
- A task is considered complete when its primary objective has been met and verified.
- Verification may involve testing, code review, or confirmation from relevant stakeholders.
- The `shell.log` or similar execution logs can be reviewed to identify tasks that have reached a state of completion (e.g., "Acknowledged. The Emacs Lisp integration for the Gemini CLI is complete.").

### 4. Processing Completed Tasks:

#### 4.1. Move Task Files:
- Once a task is confirmed complete, move its associated markdown file (e.g., `prompts/task_XXX.md`) and any generated output files (e.g., `prompts/task_XXX.md.out1.md`) to a designated `completed_tasks/` directory.
- **Example Command:**
  ```bash
  mv prompts/task_XXX.md /path/to/completed_tasks/
  mv prompts/task_XXX.md.out1.md /path/to/completed_tasks/
  ```
  *(Note: The `/path/to/completed_tasks/` should be the specific directory for completed tasks, e.g., `source/github/meta-introspector/git-submodule-tools-rs/completed_tasks/`)*

**Note on Helper Scripts**: If you create any helper shell scripts to automate the moving or processing of task files, always run `shellcheck` on them to ensure code quality and catch potential errors. Refer to [Memo: Use Shellcheck Always After Changes](../../docs/memos/Shellcheck_Always_After_Changes.md) for details.

#### 4.2. Review and Summarize Results:
- Review the content of the completed task file and its output files.
- Extract key outcomes, changes, and any relevant instructions or observations.
- This summary will be used for updating the project's main `task.md` file.

#### 4.3. Testing (if applicable):
- If the task involved a new feature or fix, ensure it has been adequately tested.
- Document the testing methodology and results. For tasks that cannot be directly tested in the current environment (e.g., Emacs Lisp integration), provide clear instructions for manual testing by the user.

### 5. Documenting Task Completion in `task.md`:
- Update the `## Recent Accomplishments:` section in the project's main `task.md` file.
- Add a concise entry for the completed task, summarizing its outcome.
- Include references to relevant documentation (e.g., `.out1.md` files) or instructions for further details.
- **Example Update:**
  ```markdown
  -   Developed and integrated Emacs Lisp functions for Gemini CLI interaction, enabling interactive commands and automated task processing within Emacs. (See prompts/task_001_emacs_lisp.md.out1.md for details and usage instructions).
  ```

### 6. Archiving (Optional):
- Periodically, completed tasks in the `completed_tasks/` directory may be archived or further organized as per project needs.

## Related Documents:
- [CRQ-016: Submodule Nixification and Flake Refactoring](docs/crqs/CRQ_016_Submodule_Nixification.md)
- [Memo: Use Shellcheck Always After Changes](docs/memos/Shellcheck_Always_After_Changes.md)
- [Contributing with CRQs and SOPs Tutorial](docs/tutorials/Contributing_with_CRQs_and_SOPs.md)
- `docs/crqs/CRQ_Standardize_Task_Management.md`
- `task.md`

## Revision History:
- [Date]: Initial Draft
