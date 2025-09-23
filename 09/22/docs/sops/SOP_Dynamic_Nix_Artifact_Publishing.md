# SOP: Dynamic Nix Artifact Publishing

*   **ID:** SOP-009
*   **Author:** Gemini
*   **Status:** Active
*   **Related CRQ:** CRQ-032

## 1. Purpose

To provide a clear, step-by-step process for publishing Nix artifacts to a Git repository in a dynamic and centralized manner.

## 2. Scope

This SOP applies to all contributors and covers the publishing of any Nix artifact (derivation output) to a Git-based binary cache or store.

## 3. Procedure

The dynamic artifact publishing process is centered around the `scripts/publish_nix_artifact_to_git.sh` script.

### 3.1. Step 1: Identify the Flake Attribute

*   **Objective:** Determine the full flake attribute path for the Nix artifact you want to publish.
*   **Action:**
    1.  Locate the `flake.nix` file that defines the desired package or output.
    2.  Identify the attribute path to the artifact. For example: `.#packages.aarch64-linux.my-package` or `./my-flake#apps.aarch64-linux.my-app`.

### 3.2. Step 2: Identify the Target Repository

*   **Objective:** Determine the URL of the Git repository where the artifact will be stored.
*   **Action:**
    1.  Ensure the target repository is a valid Git repository, accessible for writing.
    2.  For this project, the primary binary store is `https://github.com/meta-introspector/crq-binstore.git`.

### 3.3. Step 3: Execute the Publishing Script

*   **Objective:** Run the generic publishing script with the identified parameters.
*   **Action:**
    1.  Open a terminal in the root of the project.
    2.  Execute the `scripts/publish_nix_artifact_to_git.sh` script, providing the flake attribute and repository URL as arguments.

    ```bash
    ./scripts/publish_nix_artifact_to_git.sh \
      "<flake-attribute-path>" \
      "<repository-url>"
    ```

    **Example:**

    ```bash
    ./scripts/publish_nix_artifact_to_git.sh \
      ".#packages.aarch64-linux.my-package" \
      "https://github.com/meta-introspector/crq-binstore.git"
    ```

### 3.4. Step 4: Verify the Publication

*   **Objective:** Ensure the artifact was successfully published.
*   **Action:**
    1.  Check the script's output for any errors.
    2.  Navigate to the target Git repository and verify that a new commit has been pushed containing the `.nar` file for your artifact.
    3.  Verify that the commit message includes the name of the artifact.

### 3.5. Step 5: Update the README

*   **Objective:** Update the `README.md` file in the binary store repository with a link to the newly published artifact.
*   **Action:**
    1.  Clone the binary store repository locally if you haven't already.
    2.  Open the `README.md` file in a text editor.
    3.  Add a new entry to the index of artifacts, including the name of the artifact and a link to the `.nar` file in the repository.
    4.  Commit and push the changes to the `README.md` file.

## 4. Related Documents

*   [CRQ-032: Dynamic Nix Artifact Publishing](docs/crqs/CRQ_032_Dynamic_Nix_Artifact_Publishing.md)
