# SOP: CRQ and SOP Review for New Task Creation

## Purpose:
This Standard Operating Procedure (SOP) outlines the process for periodically reviewing existing Change Requests (CRQs) and Standard Operating Procedures (SOPs) to identify areas for improvement, address gaps, and generate a new set of actionable development tasks. This ensures that project documentation remains relevant, comprehensive, and drives continuous progress.

## Scope:
This SOP applies to all CRQs and SOPs within the project's `docs/crqs/` and `docs/sops/` directories, respectively. The output of this process is a set of new tasks, typically defined in `prompts/task_XXX.md` files.

## Procedure:

### 1. Schedule and Preparation:
-   **Frequency**: Conduct reviews on a regular basis (e.g., weekly, bi-weekly, monthly) or as triggered by significant project milestones or changes.
-   **Reviewer(s)**: Assign a dedicated reviewer or a team to perform the review.
-   **Gather Documents**: Ensure all current CRQs and SOPs are accessible in their respective directories.

### 2. Review of Existing CRQs:

1.  **Status Check**: For each CRQ, verify its current status (e.g., "Proposed", "Approved", "Implemented", "Deferred", "Rejected").
2.  **Implementation Verification**: For CRQs marked "Implemented", confirm that the proposed changes have been fully integrated and are functioning as intended.
3.  **Effectiveness Assessment**: Evaluate if the implemented CRQ has achieved its intended benefits.
4.  **Identify Gaps/New Needs**:
    -   Are there any outstanding issues related to the CRQ that were not fully addressed?
    -   Has the implementation of this CRQ revealed new requirements or potential improvements?
    -   Are there any CRQs that have been "Deferred" that should now be revisited?
5.  **Documentation Review**: Ensure the CRQ document itself is clear, concise, and accurately reflects the change.

### 3. Review of Existing SOPs:

1.  **Clarity and Completeness**: Read through each SOP to ensure it is easy to understand, unambiguous, and covers all necessary steps.
2.  **Accuracy**: Verify that the procedures described in the SOP are still accurate and reflect current best practices and tools.
3.  **Adherence**: Assess if the SOPs are being consistently followed in practice.
4.  **Identify Gaps/New Needs**:
    -   Are there any project processes that lack a formal SOP?
    -   Are there any steps in existing SOPs that could be automated or made more efficient?
    -   Has the introduction of new tools or technologies rendered any part of an SOP obsolete or in need of an update?
5.  **Cross-referencing**: Ensure SOPs correctly reference relevant CRQs, other SOPs, and task files.

### 4. New Task Generation:

Based on the review of CRQs and SOPs, generate a list of new tasks. Each new task should:

1.  **Be Specific and Actionable**: Clearly define what needs to be done.
2.  **Have a Clear Objective**: State the desired outcome of the task.
3.  **Reference Relevant Documents**: Link back to the CRQ or SOP that prompted its creation.
4.  **Be Defined in a `prompts/task_XXX.md` File**: Follow the standard task documentation format.

**Examples of New Tasks:**
-   "Create SOP for X process." (from SOP review, identifying a gap)
-   "Implement feature Y as described in CRQ Z." (from CRQ review, identifying an approved but not yet implemented change)
-   "Refactor script A to improve efficiency as suggested in SOP B." (from SOP review, identifying an automation opportunity)
-   "Investigate why CRQ C's implementation is not fully effective." (from CRQ review, identifying an issue with implementation)

### 5. Prioritization and Assignment:
-   Prioritize the newly generated tasks based on project goals, impact, and dependencies.
-   Assign tasks to appropriate team members or the agent for execution.

### 6. Documentation of Review Findings:
-   Document the findings of the CRQ and SOP review, including identified gaps, areas for improvement, and the rationale behind the new tasks. This can be a simple markdown file or an update to a project status document.

## Related Documents:
- [CRQ-016: Submodule Nixification and Flake Refactoring](docs/crqs/CRQ_016_Submodule_Nixification.md)
- [Memo: Use Shellcheck Always After Changes](docs/memos/Shellcheck_Always_After_Changes.md)
- `docs/crqs/` (directory)
- `docs/sops/` (directory)
- `prompts/` (directory for new tasks)
- `task.md`

## Revision History:
- [Date]: Initial Draft
