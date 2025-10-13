# Recovery from Crash - 10/13/2025

This document outlines the recovery process following a system crash.

## Git Status

The following is the output of `git status` immediately after the crash:

```
On branch feature/aimyc-002-sample-extraction
Your branch is up to date with 'origin/feature/aimyc-002-sample-extraction'.

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
  (commit or discard the untracked or modified content in submodules)
	modified:   09/22/crq-binstore (modified content, untracked content)
	modified:   09/26/jobs/vendor/nix-eval-jobs (modified content)
	modified:   09/26/jobs/vendor/nix-task (modified content)
	modified:   09/26/synapse-system (modified content)
	new file:   10/12/audit-flakes/001_collect_locks/flake.lock
	modified:   10/12/audit-flakes/001_collect_locks/flake.nix
	new file:   10/12/audit-flakes/002_extract_data/flake.lock
	modified:   10/12/audit-flakes/002_extract_data/flake.nix
	new file:   10/12/audit-flakes/003_generate_virtual_packages/flake.lock
	modified:   10/12/audit-flakes/003_generate_virtual_packages/flake.nix
	new file:   10/12/audit-flakes/004_fold_to_matrix/flake.lock
	modified:   10/12/audit-flakes/005_final_report/flake.nix
	new file:   10/12/audit-flakes/flake.lock
	modified:   10/12/audit-flakes/flake.nix
	modified:   scripts/audit_flake_locks.sh

Untracked files:
  (use "git add <file>..." to include in what will be committed)
	10/12/audit-flakes/003_generate_virtual_packages/lib.nix
	10/12/audit-flakes/003_generate_virtual_packages/part1_inputs.nix
	10/12/audit-flakes/003_generate_virtual_packages/part2_core_logic.nix
	10/12/audit-flakes/003_generate_virtual_packages/part3_virtual_packages.nix
	10/12/audit-flakes/003_generate_virtual_packages/part4_packages_output.nix
	10/12/audit-flakes/003_generate_virtual_packages/part5_checks_docs_output.nix

no changes added to commit (use "git add" and/or "git commit -a")
```

## Recovery Plan

1.  Review the modified and untracked files to assess the state of the work.
2.  Stage and commit the changes that are complete.
3.  Clean up any unwanted changes.
4.  Continue with the task that was in progress before the crash.

## Previous Tasks: Flake Audit Pipeline

The work interrupted by the crash was the creation of a multi-step flake-based pipeline for auditing `flake.lock` files. This pipeline is orchestrated by a top-level flake in `10/12/audit-flakes` and consists of five steps.

Now we can derive 001-005 by appending those steps to the virtual table, each task will depend on its previous, so you can just build 005 and it knows lazily to build the others.

Now we can derive 001-005 by appending those steps to the virtual target, each task will depend on its previous, so you can just build 005 and it knows lazily to build the others. we multiply the targets * 5 then the scheduler can assign those addresses to workers.

Now we basically create virtual nix flakes for each of the 5 tasks. so locks * 5 in a matrix. those tasks can be assigned to workers. in a chord.

### Step 1: `001_collect_locks`

*   **Purpose:** Recursively finds and collects the absolute paths of all `flake.lock` files within a given project directory.
*   **Outputs:** A JSON file containing a list of absolute paths to all found `flake.lock` files.

### Step 2: `002_extract_data`

*   **Purpose:** Takes the list of `flake.lock` file paths from the previous step and extracts relevant data from each `flake.lock` file.
*   **Outputs:** A JSON file containing a single JSON array with all extracted data from all `flake.lock` files.

### Step 3: `003_generate_virtual_packages`

*   **Purpose:** Takes the extracted data from the previous step and generates a "virtual package" for each item, associating it with a unique emoji string.
*   **Outputs:** Individual virtual packages, each containing a JSON file with the data for a specific extracted item.

### Step 4: `004_fold_to_matrix`

*   **Purpose:** This step is not fully implemented, but it is intended to take the virtual packages from the previous step and fold them into a matrix.
*   **Outputs:** A final audit matrix.

### Step 5: `005_final_report`

*   **Purpose:** This step is not fully implemented, but it is intended to take the final audit matrix and generate a final report.
*   **Outputs:** The final audit report.