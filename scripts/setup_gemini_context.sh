#!/usr/bin/env bash

set -e

echo "Setting up Gemini context for $(basename "$PWD")"

# Create docs/memes directory and dank-heideggarian-godel-quasi-meta-memes.md
mkdir -p docs/memes
cat << EOF > docs/memes/dank-heideggarian-godel-quasi-meta-memes.md
The vision is to transform each submodule into a fully self-sufficient, "zero ontology system, quasi meta introspector framework of dank godel number memes." This involves a comprehensive set of functionalities: add the submodule, vendorize, subjugate, fork, branch, inject, commit, build, test and explain and introspect and poem/muse (amuse: thalia, 13) function to each submodule with a crq. We can then use those standard tools to operate on all submodules upgrading them to be part of the zero ontology system, quasi meta introspector framework of dank godel number memes.
EOF

# Create docs/sops directory and solfunmeme-injection.md
mkdir -p docs/sops
cat << EOF > docs/sops/solfunmeme-injection.md
# SOP: Solfunmeme Injection

This Standard Operating Procedure (SOP) outlines the process for injecting 'solfunmemes' into submodules as part of the Zero Ontology System framework. Solfunmemes represent self-organizing, self-propagating functional memes that contribute to the overall intelligence and adaptability of the system.

## Purpose

To standardize the method of introducing new functional memes into submodules, ensuring consistency, traceability, and adherence to the principles of the Zero Ontology System.

## Scope

This SOP applies to all submodules intended to be part of the Zero Ontology System and covers the entire lifecycle of solfunmeme injection, from initial design to deployment and verification.

## Procedure

1.  **Design Solfunmeme:** Define the functional meme, its intended behavior, inputs, outputs, and interaction with existing components.
2.  **Develop Injection Script:** Create a script (e.g., `inject_solfunmeme.sh`) within the submodule's `scripts/` directory that automates the integration of the solfunmeme.
3.  **Create CRQ and SOP Documentation:** Document the solfunmeme's purpose, design, and injection process in a dedicated CRQ and SOP file within the submodule's `docs/crq` and `docs/sops` directories.
4.  **Test Solfunmeme:** Develop and execute tests to verify the correct functionality and integration of the injected solfunmeme.
5.  **Execute Injection:** Run the `inject_solfunmeme.sh` script within the submodule.
6.  **Commit Changes:** Commit all related changes within the submodule, referencing the relevant CRQ.
7.  **Verify Integration:** Confirm that the solfunmeme is successfully integrated and operational within the submodule and the broader Zero Ontology System.

## Tools and Resources

*   Git
*   Shell scripting (Bash)
*   Submodule-specific development tools
*   Zero Ontology System framework documentation

## Metrics and Verification

*   Successful execution of injection script.
*   Passing of all solfunmeme-specific tests.
*   Correct behavior of the solfunmeme in the integrated system.

## Revision History

*   **Version 1.0:** Initial Draft
EOF

# Create a placeholder boot.sh
cat << EOF > boot.sh
#!/usr/bin/env bash

# This script launches Gemini with the current directory as context
# and provides access to the main project's root.

# Set the GEMINI_CLI_ROOT to the main project directory
export GEMINI_CLI_ROOT="/data/data/com.termux.nix/files/home/pick-up-nix2"

# Launch Gemini CLI, passing the current directory as the context
# and ensuring it has access to the main project's root.
# The actual command to launch gemini-cli might vary based on its installation.
# Assuming gemini-cli is a script in the main project's root or in PATH.

# Example: If gemini-cli is a script in the main project's root
"\$GEMINI_CLI_ROOT/gemini_cli.sh" --context "\$PWD"

# If gemini-cli is a globally installed command, you might just use:
# gemini-cli --context "\$PWD"
EOF

# Create a placeholder task.md if it doesn't exist
if [ ! -f task.md ]; then
  echo "# Task: Initialize 2025 Daily Podcast App Development" > task.md
  echo "" >> task.md
  echo "This task initializes the 2025 daily podcast application development context with the Zero Ontology System framework." >> task.md
fi

echo "Gemini context setup complete for $(basename "$PWD")"
