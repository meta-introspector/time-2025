#!/usr/bin/env bash

# lib_github_parsing.sh
#
# This library provides functions for parsing and extracting GitHub repository information
# from various formats (e.g., flake.nix inputs, URLs).

# Function to extract owner/repo from 'github:owner/repo' format
# Usage: get_owner_repo_from_github_flake_input <input_string>
# Example: get_owner_repo_from_github_flake_input "github:NixOS/nixpkgs" -> "NixOS/nixpkgs"
get_owner_repo_from_github_flake_input() {
    local input_string="$1"
    echo "$input_string" | grep -oP 'github:\K[^/]+/[^/]+'
}

# Function to extract repository name from 'github:owner/repo' format
# Usage: get_repo_name_from_github_flake_input <input_string>
# Example: get_repo_name_from_github_flake_input "github:NixOS/nixpkgs" -> "nixpkgs"
get_repo_name_from_github_flake_input() {
    local input_string="$1"
    get_owner_repo_from_github_flake_input "$input_string" | cut -d'/' -f2
}

# Function to extract full HTTPS GitHub URLs
# Usage: get_https_github_urls <input_string>
# Example: get_https_github_urls "https://github.com/owner/repo" -> "https://github.com/owner/repo"
get_https_github_urls() {
    local input_string="$1"
    echo "$input_string" | grep -oE 'https?://github.com/[a-zA-Z0-9_.-]+/[a-zA-Z0-9_.-]+'
}

# Function to extract full SSH GitHub URLs
# Usage: get_ssh_github_urls <input_string>
# Example: get_ssh_github_urls "git@github.com:owner/repo.git" -> "git@github.com:owner/repo.git"
get_ssh_github_urls() {
    local input_string="$1"
    echo "$input_string" | grep -oE 'git@github.com:[a-zA-Z0-9_.-]+/[a-zA-Z0-9_.-]+\.git'
}

# Function to extract repository name from a full GitHub URL (HTTPS or SSH)
# Usage: get_repo_name_from_github_url <input_string>
# Example: get_repo_name_from_github_url "https://github.com/owner/repo" -> "repo"
# Example: get_repo_name_from_github_url "git@github.com:owner/repo.git" -> "repo"
get_repo_name_from_github_url() {
    local input_string="$1"
    local repo_name=""
    if [[ "$input_string" =~ ^https?://github.com/ ]]; then
        repo_name=$(echo "$input_string" | rev | cut -d'/' -f1 | rev)
    elif [[ "$input_string" =~ ^git@github.com: ]]; then
        repo_name=$(echo "$input_string" | rev | cut -d'/' -f1 | cut -d'.' -f2 | rev)
    fi
    echo "$repo_name"
}
