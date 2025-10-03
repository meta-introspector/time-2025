# SOP: Enforcing GitHub URL Policy for Nix Flake Inputs

## 1. Purpose:
This SOP outlines the procedure for ensuring all Nix flake inputs adhere to the `github:meta-introspector` URL policy, eliminating `path:` references for improved maintainability, reproducibility, and collaboration.

## 2. Scope:
Applies to all `flake.nix` files within `meta-introspector` projects.

## 3. Policy:
All Nix flake inputs MUST use `github:meta-introspector` URLs. `path:` references are strictly prohibited.

## 4. Procedure:

### 4.1. Identify `path:` References:
   a. Run the pre-commit hook: `bash scripts/nix_url_check.sh`
   b. Review the output for `ERROR: ... Found 'path:' reference in a flake URL.`
   c. Note down all file paths and the corresponding `path:` URLs.

### 4.2. Determine GitHub URL for `path:` Reference:
   a. For each identified `path:` reference, determine its absolute path relative to the project root.
   b. Construct the GitHub URL using the format: `github:meta-introspector/<repo_name>/<branch_name>?dir=<relative_path_from_repo_root>`
      *   `<repo_name>`: Typically `time-2025` for sub-flakes within this project.
      *   `<branch_name>`: The current development branch (e.g., `feature/foaf`).
      *   `<relative_path_from_repo_root>`: The path to the flake's directory from the root of the `time-2025` repository.

### 4.3. Replace `path:` Reference with GitHub URL:
   a. Open the `flake.nix` file containing the `path:` reference.
   b. Replace the `path:` URL with the constructed `github:` URL.
   c. Ensure the `flake.nix` file is syntactically correct after the change.

### 4.4. Update Flake Lock File:
   a. Navigate to the directory of the modified `flake.nix` file.
   b. Run `nix flake update` to update the lock file and resolve the new GitHub URL.

### 4.5. Verify Changes:
   a. Run `bash scripts/nix_url_check.sh` again to confirm no `path:` references remain.
   b. Run `nix flake check` on the modified flake (or the entire project) to ensure it evaluates correctly.

### 4.6. Commit and Push:
   a. Add the modified `flake.nix` file(s) and `flake.lock` file(s) to Git.
   b. Commit with a descriptive message (e.g., `fix(nix-flakes): Replace path: references with github: URLs in <file_name>`).
   c. Push the changes to the remote repository.
