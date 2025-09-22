# Standard Operating Procedure: Setting Up a New Git Submodule

## 1. Purpose
This SOP outlines the process for setting up a new Git submodule within the main repository, using a local bare Git repository as the upstream source. This procedure is particularly useful for managing large data sets or independent components that need to be version-controlled separately but included in the main project.

## 2. Scope
This SOP applies to all developers and contributors working on projects that require the integration of new Git submodules.

## 3. Prerequisites
*   Access to the main Git repository.
*   Git installed and configured.
*   Understanding of basic Git commands.

## 4. Procedure

### 4.1. Create a Local Bare Git Repository for the Submodule
This bare repository will serve as the initial upstream for your new submodule.

```bash
mkdir -p ~/git/<submodule_name>
git init --bare ~/git/<submodule_name>
```
*Replace `<submodule_name>` with the desired name for your submodule (e.g., `data`).*

### 4.2. Prepare the Submodule Directory in the Main Repository
If the directory for the submodule already exists and contains files, you must move those files to a temporary location and remove the directory before adding the submodule.

```bash
# If the submodule directory exists and contains files:
mkdir -p /tmp/<submodule_name>_temp
mv <submodule_directory_path>/* /tmp/<submodule_name>_temp/
rm -rf <submodule_directory_path>/
```
*Replace `<submodule_name>` with the actual name of your submodule and `<submodule_directory_path>` with the path to the submodule's directory within the main repository (e.g., `data/`).*

### 4.3. Add the Submodule to the Main Repository
Navigate to the root of your main repository and add the submodule.

```bash
git submodule add <path_to_bare_repo> <submodule_directory_path>
```
*Replace `<path_to_bare_repo>` with the absolute path to the bare repository created in Step 4.1 (e.g., `/data/data/com.termux.nix/files/home/git/data`).*
*Replace `<submodule_directory_path>` with the desired path for the submodule within your main repository (e.g., `data`).*

### 4.4. Populate the Submodule with Initial Content (if applicable)
If you moved files to a temporary directory in Step 4.2, move them into the newly initialized submodule directory.

```bash
mv /tmp/<submodule_name>_temp/* <submodule_directory_path>/
```
*Replace `<submodule_name>` and `<submodule_directory_path>` as before.*

### 4.5. Commit Changes within the Submodule
Navigate into the submodule directory, add the new files, and commit them.

```bash
cd <submodule_directory_path>
git add .
git commit -m "Initial commit for <submodule_name> submodule"
git push origin main # Or the appropriate branch/remote
cd ..
```
*Replace `<submodule_directory_path>` and `<submodule_name>` as before. Adjust `git push origin main` if your submodule's default branch or remote is different.*

### 4.6. Commit the Submodule Addition in the Main Repository
Navigate back to the root of your main repository, add the submodule changes, and commit.

```bash
git add <submodule_directory_path> .gitmodules
git commit -m "Add <submodule_name> submodule"
```
*Replace `<submodule_directory_path>` and `<submodule_name>` as before.*

## 5. Verification
After completing the procedure, verify the submodule setup:
*   Run `git status` in the main repository to ensure no pending changes related to the submodule.
*   Run `git submodule status` to confirm the submodule is correctly initialized and pointing to the expected commit.
*   Navigate into the submodule directory and run `git log` to confirm the initial commit is present.
*   If any new scripts were created or existing ones modified within the submodule, run `shellcheck` on them. Refer to [Memo: Use Shellcheck Always After Changes](docs/memos/Shellcheck_Always_After_Changes.md) for details.

## 6. Future Considerations
*   **Pushing to a Remote (e.g., Hugging Face):** Once the local setup is complete, you can add a remote to your submodule's bare repository and push its content to a public or private hosting service.
*   **Updating Submodules:** To pull updates from the submodule's remote, use `git submodule update --remote`.
*   **Cloning Repositories with Submodules:** When cloning the main repository, remember to initialize and update submodules using `git submodule update --init --recursive`.

## 7. Related Documents

*   `SOP_Submodule_Nixification.md` - For integrating Nix flakes into submodules.

## 8. Next Steps: Nixification

Once a submodule is successfully set up, the next logical step is to integrate it into the project's Nix ecosystem. Refer to `SOP_Submodule_Nixification.md` for detailed instructions on how to create or update `flake.nix` files within the submodule and integrate them into the main project's Nix flake.
