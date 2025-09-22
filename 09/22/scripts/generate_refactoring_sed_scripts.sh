#!/usr/bin/env bash

# This script contains sed commands to replicate the refactoring
# performed by the Gemini CLI for Git access in shell scripts.
# It is intended for documentation and auditing purposes.

declare -A FILES_TO_REFACTOR

# Define refactoring rules for each file
# Key: file_path
# Value: array of sed commands

# fix_submodules.sh
FILES_TO_REFACTOR["fix_submodules.sh"]=(
  's/git status --ignore-submodules/git_status_superproject_ignore_submodules/g'
  's/git status/git_status_submodule/g'
  's/! git diff --quiet/! git_diff_quiet/g'
  's/! git diff --quiet --cached/! git_diff_quiet_cached/g'
  's/git add \./git_add_all/g'
  's/git commit -m "Update submodule content"/git_commit_message "Update submodule content"/g'
  's/git commit -m "Add untracked files in submodule"/git_commit_message "Add untracked files in submodule"/g'
  's/git status --porcelain/git_status_porcelain/g'
)

# todo.sh
FILES_TO_REFACTOR["todo.sh"]=(
  's|#!/usr/bin/env bash|#!/usr/bin/env bash\n\nsource "$(dirname \"$0\")"/scripts/lib_git_submodule.sh|g'
  's|! git submodule status &>/dev/null;|! git_submodule_status &>/dev/null;|g'
  's|if git status --porcelain | grep -v \"^.M\" | grep -q \"^M\";|if git_status_porcelain | grep -v \"^.M\" | grep -q \"^M\";|g'
  's|if git submodule update --init --dry-run &>/dev/null;|if git_submodule_update_init_dry_run &>/dev/null;|g'
  's|echo "git submodule update --init"|echo "git_submodule_update_init"|g'
  's|git submodule status |git_submodule_status |g'
)

# _todo_helper.sh
FILES_TO_REFACTOR["_todo_helper.sh"]=(
  's|submodule_path=\"$1\"|source \"$(dirname \"$0\")\"/scripts/lib_git_submodule.sh\n\nsubmodule_path=\"$1\"|g'
  's|git remote get-url origin 2>/dev/null|$(git remote get-url origin 2>/dev/null)|g' # This is tricky, needs to be part of a variable assignment
  's|git remote rename origin upstream|git remote rename origin upstream|g' # This is already a direct call, but needs to be wrapped in a function
  's|git remote add origin \"$new_origin_url\"|git remote add origin \"$new_origin_url\"|g' # Same as above
  's|if git fetch origin;|if git_fetch_origin;|g'
  's|gh repo fork --org meta-introspector --remote "$new_origin_url"|lib_github_fork_repo "$new_origin_url" "meta-introspector" "$repo_name"|g'
  's|git add -A|git_add_all|g'
  's|git commit -m "chore: Update submodule remotes" || true|git_commit_message "chore: Update submodule remotes" || true|g'
)

# source/github/meta-introspector/git-submodule-tools-rs/boot.sh
FILES_TO_REFACTOR["source/github/meta-introspector/git-submodule-tools-rs/boot.sh"]=(
  's|git add ${UNCLAIMED_TASK_FILE}|git_add_all|g'
  's|git commit -m \"Claimed task ${TASK_ID} - Started work\"|git_commit_message "Claimed task ${TASK_ID} - Started work"|g'
  's|git status|git_status_submodule|g'
)

# source/github/meta-introspector/git-submodule-tools-rs/vendor/meta-introspector/meta-meme/collect.sh
FILES_TO_REFACTOR["source/github/meta-introspector/git-submodule-tools-rs/vendor/meta-introspector/meta-meme/collect.sh"]=(
  's|git commit -m ''update total'' total.txt|git_commit_message "update total"|g'
  's|git push|push_to_origin_branch "HEAD"|g'
)

# source/github/meta-introspector/git-submodule-tools-rs/vendor/meta-introspector/meta-meme/commit.sh
FILES_TO_REFACTOR["source/github/meta-introspector/git-submodule-tools-rs/vendor/meta-introspector/meta-meme/commit.sh"]=(
  's|git commit -m ''step'' -a|git_add_all\n git_commit_message "step"|g'
  's|git push --set-upstream origin docs|push_to_origin_branch "docs"|g'
)

# source/github/meta-introspector/git-submodule-tools-rs/tools/update_all_submodules.sh
FILES_TO_REFACTOR["source/github/meta-introspector/git-submodule-tools-rs/tools/update_all_submodules.sh"]=(
  's|PROJECT_ROOT=$(git rev-parse --show-toplevel)|PROJECT_ROOT=$(git_get_toplevel_dir)|g'
  's|git submodule update --init --recursive|git_submodule_update_init_recursive|g'
)

# source/github/meta-introspector/git-submodule-tools-rs/task/ainix/manage_mkaiderivation_submodule.sh
FILES_TO_REFACTOR["source/github/meta-introspector/git-submodule-tools-rs/task/ainix/manage_mkaiderivation_submodule.sh"]=(
  's|run_command git submodule update --init --recursive "${SUBMODULE_PATH}"|run_command git_submodule_update_init_recursive "${SUBMODULE_PATH}"|g'
  's|run_command git submodule status "${SUBMODULE_PATH}"|run_command git_submodule_status "${SUBMODULE_PATH}"|g'
)

# source/github/meta-introspector/git-submodule-tools-rs/tools/gh_scripts/create_crq_workflow.sh
FILES_TO_REFACTOR["source/github/meta-introspector/git-submodule-tools-rs/tools/gh_scripts/create_crq_workflow.sh"]=(
  's|if git rev-parse --verify "$BRANCH_NAME" >/dev/null 2>&1;|if ensure_branch_exists_and_checkout "$BRANCH_NAME";|g'
  's|git add task.md|git_add_all|g'
  's|git commit -m "feat: Add task.md for CRQ-${CRQ_NUMBER}: ${CRQ_TITLE}"|git_commit_message "feat: Add task.md for CRQ-${CRQ_NUMBER}: ${CRQ_TITLE}"|g'
  's|git push --set-upstream origin "$BRANCH_NAME"|push_to_origin_branch "$BRANCH_NAME"|g'
)

# Apply refactoring
for file_path in "${!FILES_TO_REFACTOR[@]}"; do
  echo "Applying refactoring to $file_path..."
  for sed_command in "${FILES_TO_REFACTOR[$file_path][@]}"; do
    sed -i "$sed_command" "$file_path"
  done
done

echo "Refactoring script generation complete."