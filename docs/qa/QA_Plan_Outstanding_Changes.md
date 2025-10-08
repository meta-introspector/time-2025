## QA Plan: Outstanding Changes Review

This document outlines the Quality Assurance plan for testing and documenting the current outstanding changes in the project, integrating established methodologies like CRQ (Change Request) and SOP (Standard Operating Procedure) frameworks, and adhering to the "bott" architectural principles and the OODA Loop of Self-Introspection (Observe, Orient, Decide, Act).

---

### I. Observe: Identify & Categorize Changes

**Objective:** To gain a clear understanding of all modifications, additions, and deletions, and to categorize them for targeted testing.

1.  **Review `git status` Output:**
    *   **Staged Changes:**
        *   `.gitignore` (modified): Update to ignore `result`.
        *   `.pre-commit-config.yaml` (modified): Re-enabled `vale-system` hook.
        *   `09/crq-041.foaf.nix` (new file): Nix expression for CRQ-041.
        *   `09/poems.nix` (new file): Nix expression.
        *   `10/03/README.md` (new file): Documentation for a new component/feature.
        *   `10/03/colosseum-mirror/Makefile` (new file): Build system for `colosseum-mirror`.
        *   `10/03/colosseum-mirror/flake.nix` (new file): Nix flake for `colosseum-mirror`.
        *   `10/03/flake.nix` (new file): Nix flake for `10/03` directory.
        *   `10/03/hackathon_71_parts.nix` (new file): Nix expression related to "71-vibe" and hackathon.
        *   `Makefile` (modified): Project-level Makefile.
        *   `checker.nix` (deleted): Old Nix checker.
        *   `commit-msg-check.nix` (modified): Nix expression for commit message checks.
        *   `commit_message.txt` (modified): Example/template commit message.
        *   `crq-parser.nix` (modified): Nix parser for CRQs.
        *   `custom_commit_msg_hook.sh` (modified): Custom Git hook.
        *   `docs/crqs/CRQ_041_Colosseum_Mirror_Flake.md` (new file): CRQ documentation.
        *   `docs/memes/10/03/poetry_archive.md` (new file): Poetry archive.
        *   `docs/qa/QA_Plan_Outstanding_Changes.md` (new file): QA plan.
        *   `flake.nix` (modified): Project root flake.
        *   `scripts/check-single-commit-msg.sh` (new file): Script for checking single commit messages.
        *   `scripts/commit-msg-error.sh` (new file): Script for detailed commit message error output.
        *   `scripts/test-commit-checker.sh` (new file): Script for testing commit checker.
        *   `scripts/test-commit-checker/config.sh` (new file)
        *   `scripts/test-commit-checker/get-commit-messages.sh` (new file)
        *   `scripts/test-commit-checker/parse-entry.sh` (new file)
        *   `scripts/test-commit-checker/process-commit-message.sh` (new file)
        *   `scripts/test-commit-checker/report-summary.sh` (new file)
        *   `scripts/test-commit-checker/temp-file-management.sh` (new file)
        *   `scripts/test-commit-checker/test-commit-checker.sh` (new file)
        *   `test-commit-check.nix` (new file): Nix expression for testing commit messages.
        *   `test-commit-check/check-logic.nix` (new file)
        *   `test-commit-check/failure-derivation.nix` (new file)
        *   `test-commit-check/success-derivation.nix` (new file)
        *   `test-commit-check/test-case-crq-041.nix` (new file)
    *   **Unstaged Changes:**
        *   `09/26/jobs/vendor/nix-task` (new commits): Submodule updated.
        *   `09/26/synapse-system` (new commits, modified content): Submodule updated, but still has modified content (mach-nix).
        *   `10/03/README.md` (modified): Further modifications.
        *   `commit-msg-check.nix` (modified): Further modifications.
        *   `docs/memes/10/03/poetry_archive.md` (modified): Further modifications.
        *   `scripts/check-single-commit-msg.sh` (modified): Further modifications.
        *   `scripts/test-commit-checker.sh` (modified): Further modifications.
        *   `test-commit-check.nix` (modified): Further modifications.
    *   **Untracked Files:**
        *   `commit_message_temp.txt`

2.  **Categorize by Type & Associated CRQ/Vibe:**
    *   **Nix Flake/Expression Changes:** (`flake.nix`, `*.nix` files, `Makefile`s) - Primarily related to CRQ-016 (Nixification), CRQ-041 (Colosseum Mirror Flake), and potentially the "71-vibe" (singular, foundational choices).
    *   **Script Changes:** (`*.sh` files) - Related to automation, testing, and Git hooks.
    *   **Documentation Changes:** (`*.md` files, `docs/crqs/`) - Related to CRQ-017 (Documentation Enhancement), CRQ-041.
    *   **Submodule Changes:** (`09/26/jobs/vendor/nix-task`, `09/26/synapse-system`) - Related to CRQ-016 (Submodule Nixification).
    *   **Deleted Files:** (`checker.nix`) - Requires verification of replacement/removal impact.

---

### II. Orient: Define Test Strategy & Criteria

**Objective:** To establish clear testing methodologies and success criteria aligned with project principles.

1.  **Core Principles:**
    *   **Nix Purity:** All Nix builds must be pure and reproducible.
    *   **"bott" Framework Alignment:** Changes should align with the architectural "vibes" (primes) and principles.
    *   **OODA Loop:** The QA process itself will follow Observe, Orient, Decide, Act.

2.  **Test Categories & Success Criteria:**

    *   **Nix Flake & Expression Testing:**
        *   **Build Success:** `nix build` for all relevant flakes/derivations completes without errors.
        *   **Purity & Reproducibility:** Builds are deterministic (same inputs yield same outputs).
        *   **Correctness:** Nix expressions produce the intended outputs (e.g., correct package sets, configurations).
        *   **Dependency Graph Integrity:** `nix flake show` and `nix why-depends` reveal expected dependencies.
        *   **CRQ-016 Compliance:** Submodule flakes are correctly integrated and referenced.
        *   **CRQ-041 Compliance:** The `colosseum-mirror` flake functions as described in its CRQ.

    *   **Script Testing:**
        *   **Functionality:** Scripts execute their intended tasks correctly.
        *   **Idempotence:** Running a script multiple times yields the same result (where applicable).
        *   **Error Handling:** Scripts gracefully handle expected errors.
        *   **Shellcheck Compliance:** All shell scripts pass `shellcheck` without warnings/errors.
        *   **Git Hook Functionality:** `custom_commit_msg_hook.sh` and `scripts/test-commit-checker.sh` correctly enforce commit message policies.

    *   **Documentation Testing:**
        *   **Accuracy:** Information is factually correct and up-to-date.
        *   **Clarity & Conciseness:** Easy to understand for the target audience (n00bs, developers).
        *   **Completeness:** All necessary information is present.
        *   **Consistency:** Adheres to project style guides and terminology.
        *   **CRQ-017 Compliance:** Documentation reflects new workflows and CRQs.
        *   **Cross-referencing:** Links between CRQs, SOPs, and tutorials are correct.

    *   **Submodule Testing:**
        *   **Integration:** Submodules are correctly referenced and updated in the main flake.
        *   **Functionality:** Submodule-provided components build and function as expected within the main project.
        *   **Git State:** Submodules are in a clean state after operations (no modified content unless intended).

    *   **Regression Testing:**
        *   Run existing project tests (if any) to ensure no regressions were introduced.
        *   Verify core project functionality remains intact.

---

### III. Decide: Formulate Test Cases & Documentation Tasks

**Objective:** To define specific actions for testing and documentation.

1.  **Test Cases (Examples):**
    *   **Nix:**
        *   `nix build .#colosseum-mirror` (for CRQ-041)
        *   `nix flake check` for the root flake and `10/03/flake.nix`.
        *   `nix eval .#crq-parser` with various CRQ inputs.
        *   `nix build .#crq-041.foaf`
        *   `nix build .#poems`
        *   Run `nix-tree` on built derivations to inspect dependency graphs.
    *   **Scripts:**
        *   `shellcheck scripts/*.sh`
        *   Manually test `custom_commit_msg_hook.sh` by attempting commits with valid/invalid messages.
        *   Execute `scripts/test-commit-checker.sh` and verify its output.
    *   **Documentation:**
        *   Manual review of `docs/crqs/CRQ_041_Colosseum_Mirror_Flake.md` for content and links.
        *   Review `10/03/README.md`.
    *   **Submodules:**
        *   `git submodule update --init --recursive` to ensure correct fetching.
        *   `git status` to verify submodule states are clean (after any necessary submodule commits).

2.  **Documentation Tasks:**
    *   **CRQ-041:** Ensure `docs/crqs/CRQ_041_Colosseum_Mirror_Flake.md` is complete and accurate.
    *   **SOPs:** Review existing SOPs for any impact from these changes and update as necessary. Consider if a new SOP is needed for the `colosseum-mirror` workflow or the new commit checking process.
    *   **Tutorials:** Update relevant tutorials (e.g., "Contributing with CRQs") to reflect new Nix flake structures or script usage.
    *   **`README.md` / `GEMINI.md`:** Update the project overview and context if these changes introduce significant new architectural components or workflows.
    *   **`docs/memes/10/`:** Ensure any new memes are appropriately categorized and linked if they serve a documentation purpose.

---

### IV. Act: Execute & Report

**Objective:** To execute the plan, address issues, and report findings.

1.  **Execution:**
    *   Execute all defined test cases.
    *   Perform documentation reviews.
    *   Address any identified issues (bugs, inconsistencies, missing documentation).

2.  **Reporting:**
    *   Maintain a log of test results.
    *   Document any new bugs found and their resolutions.
    *   Generate a summary report of the QA findings.
    *   Ensure all relevant documentation is updated and committed.
