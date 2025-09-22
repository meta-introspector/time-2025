# SOP: Ensuring New Files are Added to Git

## 1. Purpose

This Standard Operating Procedure (SOP) outlines the process for ensuring that all new and modified files are properly tracked and added to the Git repository. This is crucial for maintaining project integrity, enabling collaboration, and ensuring that build systems (such as Nix flakes) correctly incorporate all necessary source files.

## 2. Scope

This SOP applies to all developers and contributors working on projects managed with Git, especially when introducing new files or modifying existing ones that are part of a build process (e.g., Nix flakes, source code, configuration files).

## 3. Procedure

### 3.1. Check for Untracked and Modified Files

Before committing any changes, always check the status of your Git working directory to identify untracked or modified files.

**Command:**
```bash
git status
```

**Expected Output:**
The output will list files that are:
- **Untracked:** New files that Git is not yet managing.
- **Modified:** Existing files that have been changed since the last commit.
- **Staged:** Files that are marked to be included in the next commit.

### 3.2. Add New and Modified Files to Staging

Once you have identified untracked or modified files that should be part of your changes, add them to the Git staging area.

**Command to add specific files:**
```bash
git add <file1> <file2> ...
```

**Command to add all untracked and modified files in the current directory and its subdirectories:**
```bash
git add .
```
*Caution: Use `git add .` with care, as it will stage all changes. Always review `git status` output before using this command.*

### 3.3. Verify Staged Changes

After adding files, run `git status` again to confirm that the intended files are now in the staging area.

**Command:**
```bash
git status
```

**Expected Output:**
Files that were successfully added will now appear under the "Changes to be committed" section.

### 3.4. Importance for Build Systems (e.g., Nix Flakes)

For build systems like Nix flakes, it is particularly important that all relevant source files are tracked by Git. Nix flakes often rely on the Git repository's contents as their source. If new files are not added to Git, the Nix build process may not include them, leading to build failures or unexpected behavior.

By consistently adding new files to Git, you ensure that:
- The build system has access to all required dependencies and source code.
- Changes are properly version-controlled and reproducible.
- Collaboration is seamless, as all team members work with the same set of tracked files.

## 4. Related SOPs

- [SOP_Git_Commit_Message_Guidelines](SOP_Git_Commit_Message_Guidelines.md) (if applicable)
