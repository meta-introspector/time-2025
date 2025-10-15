#!/usr/bin/env bash

set -euo pipefail

FLAKE_PATH="/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/10/12/audit-flakes/001_collect_locks"

# Function to build a lock-file-0 derivation and extract info
get_lock_info() {
  local project_name="$1"
  local override_input="$2"

  echo "Collecting lock info for $project_name..."

  #--extra-experimental-features 'nix-command flakes'
  
  local build_command="nix build path:${FLAKE_PATH}#packages.aarch64-linux.lock-file-0 --no-link --print-out-paths"

  if [[ -n "$override_input" ]]; then
    build_command+=" --override-input project ${override_input}"
  fi

  local derivation_path
  derivation_path=$(${build_command})

  local output_path
  output_path=$(nix-store -q --outputs "${derivation_path}")

  local nix_file_path
  nix_file_path=$(jq -r '.nixFilePath' "${output_path}/lock-file-info.json")

  local lock_file_path
  lock_file_path=$(jq -r '.lockFilePath' "${output_path}/lock-file-info.json")

  echo "${project_name},${nix_file_path},${lock_file_path}"
}

echo "Project,Nix File Path,Lock File Path"

# Current Project
#get_lock_info "Current Project" "/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025"
get_lock_info "time-2025" "github:meta-introspector/time-2025?ref=feature/aimyc-003-cultivation"

# pickupnix
get_lock_info "pickupnix" "github:meta-introspector/pick-up-nix?ref=feature/CRQ-016-nixify"

# streamofrandom
get_lock_info "streamofrandom" "github:meta-introspector/streamofrandom?ref=feature/foaf"
