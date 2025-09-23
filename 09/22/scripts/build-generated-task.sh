#!/usr/bin/env bash

set -euo pipefail

TASK_NAME="$1"

if [[ -z "$TASK_NAME" ]]; then
  echo "Usage: $0 <task-name>"
  echo "Example: $0 oeis-interpretation"
  exit 1
fi

GENERATOR_FLAKE="/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/22/scripts/generate-llm-tasks.nix"
GENERATED_TASKS_DIR="/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/09/22/generated-tasks"

echo "--- Building generated task: ${TASK_NAME} ---"

# Step 1: Instantiate the package that generates the flake.nix for the task
echo "Instantiating the flake generator for task: ${TASK_NAME}..."
DRV_PATH=$(nix-instantiate "${GENERATOR_FLAKE}" -A "packages.${TASK_NAME}")

if [[ -z "$DRV_PATH" ]]; then
  echo "Error: Failed to instantiate the flake generator for task ${TASK_NAME}."
  exit 1
fi
echo "Instantiation successful. Derivation path: ${DRV_PATH}"

# Step 2: Build the derivation to create the flake.nix file in generated-tasks/
echo "Building the derivation to generate flake.nix for task: ${TASK_NAME}..."
BUILD_RESULT=$(nix-build "${DRV_PATH}" --no-out-link)

if [[ -z "$BUILD_RESULT" ]]; then
  echo "Error: Failed to build the flake generator for task ${TASK_NAME}."
  exit 1
fi
echo "Flake generation successful. Output path: ${BUILD_RESULT}"

# The flake.nix for the task is now located at ${GENERATED_TASKS_DIR}/${TASK_NAME}/flake.nix

# Step 3: Build the actual LLM task from the newly generated flake
TASK_FLAKE_PATH="${GENERATED_TASKS_DIR}/${TASK_NAME}"

echo "Building the LLM task from generated flake: ${TASK_FLAKE_PATH}..."
# We need to use nix-build on the generated flake's default package
# First, instantiate the default package of the generated flake
TASK_DRV_PATH=$(nix-instantiate "${TASK_FLAKE_PATH}" -A "packages.default")

if [[ -z "$TASK_DRV_PATH" ]]; then
  echo "Error: Failed to instantiate the LLM task from generated flake ${TASK_FLAKE_PATH}."
  exit 1
fi
echo "LLM task instantiation successful. Derivation path: ${TASK_DRV_PATH}"

# Now, build the LLM task
LLM_TASK_BUILD_RESULT=$(nix-build "${TASK_DRV_PATH}" --no-out-link)

if [[ -z "$LLM_TASK_BUILD_RESULT" ]]; then
  echo "Error: Failed to build the LLM task from generated flake ${TASK_FLAKE_PATH}."
  exit 1
fi
echo "LLM task build successful. Output path: ${LLM_TASK_BUILD_RESULT}"

echo "--- Task ${TASK_NAME} built successfully. ---"
echo "To run the task, execute: ${LLM_TASK_BUILD_RESULT}/bin/run-llm-task.sh"
