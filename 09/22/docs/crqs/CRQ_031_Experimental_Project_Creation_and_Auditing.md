# CRQ-031: Experimental Project Creation and Auditing

*   **Status:** Proposed
*   **Author:** Gemini
*   **Date:** 2025-09-21

## 1. Problem Statement

The project currently lacks a standardized and auditable process for creating experimental projects. Without a dedicated mechanism, experimental efforts can become disorganized, difficult to track, and lack the necessary traceability for our "Self-Proving Intelligence" vision. This hinders the systematic growth and integration of new "dank quasi meta memes."

## 2. Proposed Solution

Develop a script (`scripts/create_experiment.sh`) and an accompanying Standard Operating Procedure (`docs/sops/SOP_Experimental_Project_Creation_and_Auditing.md`) to automate the creation of experimental project directories. This process will ensure consistent placement within the `streamofrandom` structure and generate an audit log for each experiment created, enhancing traceability and adherence to the "digital mycology" procedure.

## 3. Scope

*   **In Scope:**
    *   Creation of the `scripts/create_experiment.sh` script.
    *   Creation of `docs/sops/SOP_Experimental_Project_Creation_and_Auditing.md`.
    *   Standardized creation of experimental project directories under `source/github/meta-introspector/streamofrandom/YYYY/MM/DD/[project_name]/`.
    *   Automatic generation of an audit log entry for each experiment creation.
*   **Out of Scope:**
    *   Automated content generation within the experimental project.
    *   Automated execution or management of the experiments themselves.
    *   Migration of existing experimental projects.

## 4. Implementation Details

### 4.1. Create `scripts/create_experiment.sh`

This script will:

*   Accept a project name as a command-line argument.
*   Determine the current date (`YYYY/MM/DD`) to construct the path: `source/github/meta-introspector/streamofrandom/YYYY/MM/DD/[project_name]/`.
*   Leverage `scripts/lib_search_utils.sh` for `get_project_root` and `ensure_output_dir_exists`.
*   Create the full directory structure for the new experimental project.
*   Create an audit log file (e.g., `logs/experiment_creation_audit.log`) if it doesn't exist.
*   Append a new entry to the audit log, including:
    *   Timestamp of creation.
    *   Name of the experiment.
    *   Full path to the created directory.
    *   User/agent who initiated the creation.

### 4.2. Create `docs/sops/SOP_Experimental_Project_Creation_and_Auditing.md`

This SOP will detail:

*   **Purpose:** To guide the creation of new experimental projects and ensure their auditable traceability.
*   **Procedure:** Step-by-step instructions on how to use `scripts/create_experiment.sh`.
*   **Audit Log:** Explanation of the audit log format, content, and location.
*   **Digital Mycology Connection:** Emphasize how this process supports the "digital mycology" procedure by systematically "growing" new strains of knowledge.

## 5. Expected Outcomes

*   Standardized and auditable creation of experimental projects.
*   Improved organization and traceability of experimental efforts.
*   Enhanced adherence to the Quality Doctrine and the "digital mycology" philosophy.

## 6. Rollback Plan

To roll back, this CRQ can be marked as "Deprecated" or "Rejected." The created script and SOP files can be removed. Any created experiment directories would need to be manually deleted.
