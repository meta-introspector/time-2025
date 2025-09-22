# CRQ-028: Task Template Definition

*   **Status:** Proposed
*   **Author:** Gemini
*   **Date:** 2025-09-21

## 1. Problem Statement

As the project evolves, there is a growing need for a standardized and minimal template for defining new tasks. Without a consistent structure, task descriptions can be ambiguous, incomplete, or difficult to track, leading to inefficiencies in task management and execution.

## 2. Proposed Solution

Define a minimal task template, composed of atomic, composable parts, that reflects the project's core identity as represented by the `zos` sequence (`[0,1,2,3,5,7,11,13,17,19,23]`). This template will ensure clarity, consistency, and traceability for all defined tasks.

## 3. Scope

*   **In Scope:**
    *   Definition of the minimal task template structure.
    *   Integration of the `zos` sequence into the template's philosophy or numbering scheme.
    *   Creation of the template file: `templates/task_template.md`.
*   **Out of Scope:**
    *   Implementation of a task management system.
    *   Automated generation of tasks from the template.

## 4. Implementation Details

### 4.1. Task Template Structure

The task template will be a Markdown file (`templates/task_template.md`) and will include the following atomic parts:

*   **Task ID:** A unique identifier for the task. This could potentially be linked to the `zos` sequence or a derivative thereof.
*   **Title:** A concise and descriptive name for the task.
*   **Description:** A clear explanation of what the task entails, its purpose, and expected outcomes.
*   **Atomic Components:** A breakdown of the task into smaller, manageable, and composable sub-tasks or steps. Each component should be self-contained and contribute to the overall task.
*   **Dependencies:** Any prerequisites or other tasks that must be completed before this task can begin.
*   **Status:** Current state of the task (e.g., Proposed, In Progress, Completed, Blocked).
*   **Assignee:** The individual or team responsible for the task.
*   **Related CRQ/SOPs:** Links to relevant Change Requests or Standard Operating Procedures.

### 4.2. Integration of `zos` as Core Identity

The `zos = [0,1,2,3,5,7,11,13,17,19,23]` sequence, representing our core identity, will be integrated into the task template's philosophy. This could manifest as:

*   **Philosophical Basis for Decomposition:** Encouraging task decomposition into prime-like, indivisible (atomic) units, reflecting the nature of the `zos` sequence.
*   **Numbering Scheme (Optional):** The `zos` sequence could inspire a numbering or versioning scheme for task components or iterations, emphasizing the project's unique identity.

## 5. Expected Outcomes

*   Standardized task definition across the project.
*   Improved clarity and understanding of individual tasks.
*   Enhanced ability to track and manage task progress.
*   Reinforcement of the project's core identity (`zos`) in its operational processes.

## 6. Rollback Plan

This CRQ defines a template. To roll back, this CRQ can be marked as "Deprecated" or "Rejected," and the `templates/task_template.md` file can be removed. No direct code changes are made by this CRQ.
