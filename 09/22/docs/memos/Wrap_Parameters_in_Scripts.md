## Memo: Wrap Anything with Parameters in a Script

### Principle
For any operation that involves parameters, especially those executed repeatedly or in automated workflows, a dedicated shell script should be created to encapsulate the command and its parameters.

### Rationale
1.  **Robustness:** Scripts provide a controlled environment for parameter validation, error handling, and consistent execution, reducing the likelihood of human error.
2.  **Reusability:** Encapsulating operations in scripts makes them easily reusable across different contexts, by other users, or in automated systems (e.g., CI/CD pipelines).
3.  **Readability and Maintainability:** Scripts improve the clarity of complex operations by abstracting away intricate command-line syntax. Changes to parameters or logic can be managed in a single, version-controlled file.
4.  **Version Control:** Scripts can be version-controlled, allowing for tracking of changes, collaboration, and rollback capabilities.
5.  **Automation:** Scripts are fundamental building blocks for automation, enabling seamless integration into larger workflows and reducing manual intervention.
6.  **Clarity for AI Agents:** For AI agents like Gemini, scripts provide clear, executable units of work, reducing ambiguity and improving the reliability of task execution.

### Implementation Guidelines
*   **Shebang:** Always start scripts with `#!/usr/bin/env bash` for portability.
*   **Error Handling:** Use `set -euo pipefail` to ensure scripts exit on errors and undefined variables.
*   **Parameter Parsing:** Utilize `getopts` or manual `while case` loops for robust named parameter parsing.
*   **Documentation:** Include clear comments and usage instructions within the script.
*   **Logging:** Implement consistent logging for debugging and auditing purposes.

### Example
Instead of:
`nix build ./my-flake#packages.x86_64-linux.myPackage --argstr version 1.0.0 --option substituters 'https://cache.nixos.org'`

Use a script:
`./scripts/build_my_package.sh --version 1.0.0 --use-cache`

Where `build_my_package.sh` contains the `nix build` command with its parameters.
