#!/usr/bin/env bash

# SC2154: These variables are referenced but not assigned within the script.
# They are expected to be passed as environment variables by Nix's pkgs.writeScript.
# shellcheck disable=SC2154

set -euo pipefail

# The llm-orchestrator.sh expects these as arguments
LLM_CALL_VECTOR_JSON="$(builtins.toJSON llmCallVectorDescription)"
KEY_OBJECT_JSON="$(builtins.toJSON llmPipeline.myKeyObject)"
MODEL_ROUTER_JSON="$(builtins.toJSON llmPipeline.myModelRouter)"
FLAKE_CONTENT="$(builtins.readFile flakePath)"

# Invoke the llm-orchestrator.sh script
# This will output a JSON array of LLM tasks
LLM_TASKS_JSON="$(bash "${llmPipeline.llmOrchestratorScript}" "$LLM_CALL_VECTOR_JSON" "$KEY_OBJECT_JSON" "$MODEL_ROUTER_JSON" "$FLAKE_CONTENT")"

# For now, we'll just output the first task's description as the generated doc content
# In a real scenario, we'd process all tasks and extract the actual LLM response
echo "$LLM_TASKS_JSON" | jq -r '.[0].taskDescription' > "$out"