#!/usr/bin/env bash

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
    if gh repo fork --org meta-introspector --remote; then
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
  git push -u origin "$branch_name"
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

# Function to force tag the current repository.
# Arguments:
#   $1: The tag name.
git_tag_force() {
  local tag_name="$1"
  git tag -f "$tag_name"
}

# Function to force push a tag to origin.
# Arguments:
#   $1: The tag name.
git_push_tag_force() {
  local tag_name="$1"
  git push origin "$tag_name" --force
}