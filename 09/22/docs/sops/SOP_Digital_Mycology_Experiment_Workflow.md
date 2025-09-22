# SOP: Digital Mycology Experiment Workflow

## 1. Purpose

This Standard Operating Procedure (SOP) outlines the workflow for conducting scientific experiments using the LLM (Gemini) in conjunction with Nix, Rust, and other project components. Each experiment is treated as a unique scientific endeavor, meticulously documented and reproducible.

## 2. Scope

This SOP applies to all LLM-driven scientific experiments aimed at understanding, optimizing, or extending the project's capabilities, particularly in the domains of prompt engineering, context management, and meme generation.

## 3. Procedure

### 3.1. Task Creation

1.  **Initiate a new experimental task** using the `create_experimental_task.sh` script.
    ```bash
    ./scripts/create_experimental_task.sh "{{ task_title }}"
    ```
    This will create a dedicated project directory for the experiment, pre-populated with a `task.md` and other necessary files.

2.  **Fill in `task.md`**: Document the experiment's objective, hypothesis, methodology, and expected outcomes in the newly created `task.md` file.

### 3.2. Experiment Design

1.  **Define Prompt and Context**: Clearly articulate the LLM prompt(s) to be used and the specific context (e.g., relevant SOPs, CRQs, code snippets) that will be provided to the LLM.

2.  **Identify Variables**: Determine the independent and dependent variables of the experiment. What are you changing (input) and what are you measuring (output)?

3.  **Establish Success Metrics**: Define clear, measurable criteria for evaluating the experiment's success or failure.

### 3.3. Execution

1.  **Prepare Environment**: Ensure the Nix development environment is correctly set up and all necessary tools (Rust, Gemini CLI, etc.) are available.

2.  **Run LLM**: Execute the LLM with the defined prompt and context. Capture all outputs, including generated code, text, or other artifacts.

3.  **Record Observations**: Document all observations, both expected and unexpected, during the experiment's execution.

### 3.4. Analysis and Documentation

1.  **Evaluate Results**: Compare the experiment's outcomes against the established success metrics.

2.  **Analyze Data**: Use appropriate tools (e.g., Nix, Rust) to analyze the captured outputs and observations.

3.  **Update `task.md`**: Document the experiment's results, analysis, conclusions, and any new insights or hypotheses generated.

4.  **Generate Memes/CRQs/SOPs**: If the experiment yields significant findings, consider generating new memes, CRQs, or SOPs to capture and operationalize the knowledge.

### 3.5. Reproducibility

1.  **Version Control**: Ensure all experimental artifacts (prompts, contexts, code, results) are under version control.

2.  **Nixification**: Use Nix to ensure the experiment's environment is fully reproducible.

### 3.6. Script Quality Assurance

Before executing `scripts/create_experimental_task.sh`, always run `shellcheck` on it to ensure code quality and catch potential errors. Refer to [Memo: Use Shellcheck Always After Changes](../../docs/memos/Shellcheck_Always_After_Changes.md) for details.

```bash
shellcheck scripts/create_experimental_task.sh
```

## 4. Related Documents

*   [CRQ-022: Project Quality Doctrine](docs/crqs/CRQ_022_Quality_Doctrine.md)
*   [SOP: Metaprompt Processing and Self-Query](docs/sops/SOP_Metaprompt_Processing_and_Self_Query.md)
*   `scripts/create_experimental_task.sh` (Operationalization of this SOP)
