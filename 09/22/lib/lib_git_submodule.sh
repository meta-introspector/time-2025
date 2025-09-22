#!/usr/bin/env bash

#PROJECT_ROOT="$(pwd)"
#source "${PROJECT_ROOT}/lib/lib_github_fork.sh"

# Reusable bash library for Git submodule operations.

# Function to ensure a branch exists and check it out.
# Arguments:
#   $1: The desired branch name.
ensure_branch_exists_and_checkout() {
  local branch_name="$1"
  if git rev-parse --verify "$branch_name" &>/dev/null; then
    echo "Branch '$branch_name' already exists. Checking it out."
    git checkout "$branch_name"
  else
    echo "Branch '$branch_name' does not exist. Creating and checking it out."
    git checkout -b "$branch_name"
  fi
}

# Function to ensure meta-introspector remote exists and fork if necessary.
# Arguments:
#   $1: The repository name (e.g., "my-repo").
ensure_meta_introspector_remote_and_fork() {
  local repo="$1"
  if git remote get-url origin &>/dev/null && ! git remote get-url origin | grep -q "meta-introspector"; then
    echo "Renaming origin to upstream."
    git remote rename origin upstream
  fi
  local meta_introspector_url="https://github.com/meta-introspector/$repo.git"
  if git remote | grep -q "^origin$"; then
    git remote set-url origin "$meta_introspector_url"
  else
    git remote add origin "$meta_introspector_url"
  fi
  if ! gh repo view "meta-introspector/$repo" --json name --jq . >/dev/null 2>&1; then
    echo "Creating fork..."
    if lib_github_fork_repo "meta-introspector/${repo}" "meta-introspector" "${repo}"; then
      sleep 5
    else
      exit 1
    fi
  fi
}

# Function to push to the origin branch.
# Arguments:
#   $1: The branch name to push.
push_to_origin_branch() {
  local branch_name="$1"
  echo "Pushing branch $branch_name to origin"
  git push -u origin "refs/heads/$branch_name"
}

# Function to get git status of superproject, ignoring submodules.
git_status_superproject_ignore_submodules() {
  git status --ignore-submodules
}

# Function to get git status of a submodule.
git_status_submodule() {
  git status
}

# Function to check for uncommitted changes.
git_diff_quiet() {
  git diff --quiet
}

# Function to check for staged changes.
git_diff_quiet_cached() {
  git diff --quiet --cached
}

# Function to add all changes.
git_add_all() {
  git add .
}

# Function to commit with a message.
# Arguments:
#   $1: The commit message.
git_commit_message() {
  local message="$1"
  git commit -m "$message"
}

# Function to get porcelain status.
git_status_porcelain() {
  git status --porcelain
}

# Function to get git submodule status.
git_submodule_status() {
  git submodule status
}

# Function to update and initialize submodules (dry run).
git_submodule_update_init_dry_run() {
  git submodule update --init --dry-run
}

# Function to update and initialize submodules.
git_submodule_update_init() {
  git submodule update --init
}

# Function to fetch from origin.
git_fetch_origin() {
  git fetch origin
}

# Function to get the top-level Git directory.
git_get_toplevel_dir() {
  git rev-parse --show-toplevel
}

# Function to update and initialize all submodules recursively.
git_submodule_update_init_recursive() {
  git submodule update --init --recursive
}

# Function to check if a branch exists on the remote.
# Arguments:
#   $1: The branch name.
git_remote_branch_exists() {
  local branch_name="$1"
  git ls-remote --heads origin "$branch_name" | grep -q "$branch_name"
}

# Function to check if a branch exists locally.
# Arguments:
#   $1: The branch name.
git_local_branch_exists() {
  local branch_name="$1"
  git show-ref --verify --quiet "refs/heads/$branch_name"
}

# Function to tag the current commit and push the tag.
# Arguments:
#   $1: The tag name.
#   $2: The branch name to push the tag to.
git_tag_and_push() {
  local tag_name="$1"
  local branch_name="$2"
  execute_cmd git tag -f "$tag_name" # -f to force overwrite if tag exists
  execute_cmd git push origin "refs/heads/$branch_name" --tags # Push the tag to remote
}

# Function to process a single repository: checkout, pull, commit, push, and optionally tag.
# Arguments:
#   $1: The absolute path to the repository.
#   $2: The branch name to use.
#   $3: The commit message.
#   $4: Boolean (true/false) indicating if tagging should be performed.
process_single_repo() {
  local repo_path="$1"
  local branch_name="$2"
  local commit_message="$3"
  local tags_enabled="$4" # New argument
  local repo_name=$(basename "$repo_path")

  execute_cmd echo "----------------------------------------------------"
  execute_cmd echo "Processing repository: $repo_name at $repo_path"
  execute_cmd echo "----------------------------------------------------"

  execute_cmd pushd "$repo_path" > /dev/null

  if git_remote_branch_exists "$branch_name"; then
    execute_cmd echo "Branch '$branch_name' exists on remote. Checking out and pulling."
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
    if [ "$CURRENT_BRANCH" != "$branch_name" ]; then
      execute_cmd ensure_branch_exists_and_checkout "$branch_name"
    else
      execute_cmd echo "Already on branch '$branch_name'."
    fi
    execute_cmd git pull origin "$branch_name"
  else
    execute_cmd echo "Branch '$branch_name' does not exist on remote."
    if git_local_branch_exists "$branch_name"; then
      execute_cmd echo "Branch '$branch_name' exists locally. Checking out."
      CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
      if [ "$CURRENT_BRANCH" != "$branch_name" ]; then
        execute_cmd ensure_branch_exists_and_checkout "$branch_name"
      else
        execute_cmd echo "Already on branch '$branch_name'."
      fi
    else
      execute_cmd echo "Branch '$branch_name' does not exist locally. Creating and pushing."
      execute_cmd ensure_branch_exists_and_checkout "$branch_name"
    fi
    execute_cmd push_to_origin_branch "$branch_name"
  fi

  execute_cmd echo "Staging all changes..."
  execute_cmd git_add_all

  if ! execute_cmd git diff-index --quiet HEAD; then
    execute_cmd echo "Committing changes..."
    execute_cmd git_commit_message "$commit_message"
    execute_cmd echo "Pushing changes to origin/$branch_name..."
    execute_cmd push_to_origin_branch "$branch_name"
  else
    execute_cmd echo "No changes to commit in $repo_name."
  fi

  if [ "$tags_enabled" = true ]; then # Conditional tagging
    execute_cmd echo "Tagging current commit with branch name: $branch_name"
    git_tag_and_push "$branch_name" "$branch_name" --force # Pass --force to git_tag_and_push
  fi

  execute_cmd popd > /dev/null
  execute_cmd echo ""
}

# Function to tag the current commit and push the tag.
# Arguments:
#   $1: The tag name.
#   $2: The branch name to push the tag to.
#   $3: Optional: --force to force push tags.
git_tag_and_push() {
  local tag_name="$1"
  local branch_name="$2"
  local force_push="$3" # New argument

  execute_cmd git tag -f "$tag_name" # -f to force overwrite if tag exists
  execute_cmd git push origin "refs/heads/$branch_name" --tags "$force_push" # Push the tag to remote
}

# Function to ensure a Git repository is cloned and up-to-date.
# Arguments:
#   $1: The repository URL.
#   $2: The local directory name for the repository.
#   $3: The branch to checkout/pull (default: main).
git_ensure_repo_cloned_and_updated() {
  local repo_url="$1"
  local repo_dir_name="$2"
  local branch="${3:-main}"

  if [ ! -d "$repo_dir_name" ]; then
    execute_cmd echo "Cloning repository: $repo_url into $repo_dir_name"
    execute_cmd git clone "$repo_url" "$repo_dir_name"
    execute_cmd pushd "$repo_dir_name" > /dev/null
    execute_cmd git checkout "$branch"
    execute_cmd popd > /dev/null
  else
    execute_cmd echo "Repository '$repo_dir_name' already exists. Pulling latest changes."
    execute_cmd pushd "$repo_dir_name" > /dev/null
    execute_cmd git checkout "$branch"
    execute_cmd git pull origin "$branch"
    execute_cmd popd > /dev/null
  fi
}
