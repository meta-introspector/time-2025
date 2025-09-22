#!/usr/bin/env bash

# This script onboards a project into the quality system based on its URL.
# It handles meta-introspector projects, forked repositories, and external projects.

source "$(dirname "$0")/lib_url_normalization.sh"
source "$(dirname "$0")/lib_github_parsing.sh"

PROJECT_URL="$1"

if [ -z "$PROJECT_URL" ]; then
    echo "Usage: $0 <project_url>"
    echo "Example: $0 https://github.com/meta-introspector/my-project"
    exit 1
fi

# Extract original owner and repo name from the PROJECT_URL
if [[ "$PROJECT_URL" =~ ^https?://github.com/ ]]; then
    # HTTPS URL
    repo_path=$(echo "$PROJECT_URL" | sed -E 's#https?://github.com/##')
    ORIGINAL_OWNER=$(echo "$repo_path" | cut -d'/' -f1)
    ORIGINAL_REPO_NAME=$(get_repo_name_from_github_url "$PROJECT_URL")
elif [[ "$PROJECT_URL" =~ ^git@github.com: ]]; then
    # SSH URL
    repo_path=$(echo "$PROJECT_URL" | sed -E 's#git@github.com:##' | sed 's#\.git$##')
    ORIGINAL_OWNER=$(echo "$repo_path" | cut -d'/' -f1)
    ORIGINAL_REPO_NAME=$(get_repo_name_from_github_url "$PROJECT_URL")
elif [[ "$PROJECT_URL" =~ ^github: ]]; then
    # Flake input format
    ORIGINAL_OWNER=$(echo "$PROJECT_URL" | cut -d':' -f2 | cut -d'/' -f1)
    ORIGINAL_REPO_NAME=$(get_repo_name_from_github_flake_input "$PROJECT_URL")
else
    echo "Error: Could not parse GitHub URL: $PROJECT_URL"
    exit 1
fi

# Normalize the URL for consistent parsing and meta-introspector owner
NORMALIZED_URL=$(normalize_repo_url "$PROJECT_URL")

# Extract repo name from the normalized URL (which will now have meta-introspector as owner)
REPO_NAME=$(get_repo_name_from_github_url "$NORMALIZED_URL")

echo "Onboarding project: $PROJECT_URL"
echo "Original Owner: $ORIGINAL_OWNER, Original Repo: $ORIGINAL_REPO_NAME"
echo "Normalized URL: $NORMALIZED_URL, Repo Name (under meta-introspector): $REPO_NAME"

# Function to add a new input to flake.nix
add_to_flake_nix() {
    local repo_name_arg="$1"
    local owner_arg="$2"
    local url_arg="$3"

    FLAKE_NIX_PATH="/data/data/com.termux.nix/files/home/pick-up-nix2/flake.nix"
    NEW_INPUT_ENTRY="    ${repo_name_arg} = {\n      url = \"github:${owner_arg}/${repo_name_arg}\";\n    };"

    if grep -q "template-generator-bin.url = \"\.\/tools\/template_generator_bin\";" "$FLAKE_NIX_PATH"; then
        sed -i "/template-generator-bin.url = \"\.\/tools\/template_generator_bin\";/a\${NEW_INPUT_ENTRY}" "$FLAKE_NIX_PATH"
        echo "Added ${repo_name_arg} as an input to flake.nix."
    else
        echo "Warning: Could not find 'template-generator-bin.url' in flake.nix to anchor new input. Please add manually."
    fi
}

# Logic for determining project type
if [ "$ORIGINAL_OWNER" == "meta-introspector" ]; then
    echo "Project is a meta-introspector original content."
    # Fetch info with gh cli
    echo "Fetching info for meta-introspector/$ORIGINAL_REPO_NAME using gh cli..."
    gh repo view "meta-introspector/$ORIGINAL_REPO_NAME" || {
        echo "Error: Failed to fetch repo info for meta-introspector/$ORIGINAL_REPO_NAME. Ensure gh CLI is authenticated and repo exists."
        exit 1
    }
    # TODO: Add further processing for meta-introspector original content
elif gh repo view "meta-introspector/$ORIGINAL_REPO_NAME" &>/dev/null; then # Check for fork using original repo name
    echo "Project is an external repository forked under meta-introspector."
    # Vendorize the fork using scripts/vendorize_and_fork_submodule.sh
    echo "Vendorizing fork: $PROJECT_URL"
    scripts/vendorize_and_fork_submodule.sh "$PROJECT_URL" "vendor/external/$ORIGINAL_REPO_NAME" "$ORIGINAL_REPO_NAME" || {
        echo "Error: Failed to vendorize fork $PROJECT_URL."
        exit 1
    }
    add_to_flake_nix "$ORIGINAL_REPO_NAME" "meta-introspector" "$NORMALIZED_URL" # Add to flake.nix
else
    echo "Project is an external repository not yet forked."
    # Place in sources/github/<owner>/<repo_name>
    TARGET_DIR="/data/data/com.termux.nix/files/home/pick-up-nix2/sources/github/${ORIGINAL_OWNER}/${ORIGINAL_REPO_NAME}"
    echo "Cloning external repository into $TARGET_DIR..."
    mkdir -p "$(dirname "$TARGET_DIR")"
    if [ ! -d "$TARGET_DIR" ]; then
        git clone "$PROJECT_URL" "$TARGET_DIR" || {
            echo "Error: Failed to clone $PROJECT_URL into $TARGET_DIR."
            exit 1
        }
    else
        echo "Directory $TARGET_DIR already exists. Skipping clone."
    fi
    add_to_flake_nix "$ORIGINAL_REPO_NAME" "$ORIGINAL_OWNER" "$PROJECT_URL" # Add to flake.nix
fi

echo "Project onboarding script finished."
