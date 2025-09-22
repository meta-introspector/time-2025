# SOP: Metaprompt Processing and Self-Query

*   **ID:** SOP-010
*   **Author:** Gemini
*   **Status:** Draft
*   **Related CRQ:** CRQ-022 (Quality Doctrine)

### 1. Purpose

To define a standardized procedure for the Gemini CLI to interpret, plan, and execute complex user prompts, ensuring adherence to the Project Quality Doctrine, efficient use of resources, and optimal alignment with project goals. This SOP formalizes the "Orient" phase of the OODA loop for Gemini's internal operations.

### 2. Scope

This SOP applies to all complex user prompts that require multi-step execution, strategic planning, external tool usage, or involve new intents or procedures.

### 3. Procedure

#### 3.1. Step 1: Prompt Deconstruction (Observe)

*   **Action:** Break down the user's prompt into its atomic components, identifying explicit instructions, keywords, constraints, and implicit goals.
*   **Output:** A clear understanding of the user's immediate request and underlying intent.

#### 3.2. Step 2: Self-Query / Introspection (Orient)

*   **Action:** Access and synthesize internal knowledge and project context.
    1.  **Review Internal Memories:** Consult `GEMINI.md` context files for all relevant directories, and any explicitly `save_memory` facts.
    2.  **Recall Project Documents:** Identify and review relevant CRQs, SOPs, and other documentation (e.g., `ARCHITECTURAL_VISION.md`, `README.md`) that might inform the task.
    3.  **Identify Relevant Tools:** Determine which available tools (`read_file`, `google_web_search`, `run_shell_command`, etc.) are best suited for the identified tasks.
    4.  **Anticipate Challenges:** Foresee potential issues, missing information, or ambiguities in the prompt or project context.
    5.  **Check Quality Doctrine Compliance:** Evaluate if the prompt implies a new intent (requiring a CRQ) or a new procedure (requiring an SOP).

*   **Output:** A comprehensive internal understanding of the task, its context, potential pitfalls, and compliance requirements.

#### 3.3. Step 3: Plan Formulation (Decide)

*   **Action:** Based on the self-query, formulate a detailed, step-by-step plan for execution.
    1.  **Prioritize Tasks:** Order the atomic tasks logically, identifying dependencies.
    2.  **Select Tools:** Specify the exact tools and arguments to be used for each step.
    3.  **Propose New Documentation (if necessary):**
        *   If the prompt introduces a new intent, propose a new CRQ.
        *   If the prompt requires a new, repeatable procedure, propose a new SOP.
    4.  **Adhere to DRY:** Ensure the plan avoids redundant actions or code.
    5.  **Consider Meta-SOPs:** If proposing a new SOP, ensure its structure and content align with Meta-SOP principles.

*   **Output:** A clear, actionable plan presented to the user for approval.

#### 3.4. Step 4: User Confirmation

*   **Action:** Present the formulated plan to the user and await explicit approval before execution.
*   **Output:** User approval or request for modification/clarification.

#### 3.5. Step 5: Execution (Act)

*   **Action:** Execute the approved plan using the specified tools and procedures.
*   **Output:** Results of tool executions, file modifications, or information gathered.

#### 3.6. Step 6: Verification & Reporting

*   **Action:** Verify the successful completion of the task and report findings or outcomes to the user.
*   **Output:** Confirmation of task completion, summary of results, or next steps.

### 4. Meta-SOP Compliance

This SOP itself is subject to the Meta-SOPs for SOP changes, ensuring its quality and continuous improvement.

### 5. Related Documents

*   [CRQ-022: Project Quality Doctrine](docs/crqs/CRQ_022_Quality_Doctrine.md)
*   [Memo: Use Shellcheck Always After Changes](docs/memos/Shellcheck_Always_After_Changes.md)
