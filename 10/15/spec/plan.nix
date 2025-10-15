{ lib, pkgs }:
{
  name = "task-planning-spec";
  description = "Specification for a task that takes a list of LLM tasks and generates an execution plan, potentially chunking tasks and assigning resources.";
  taskType = "planning";
  inputs = {
    llmTasks = "A derivation containing a JSON array of LLM tasks (e.g., from llm-orchestrator.sh).";
    minerProfile = "A derivation containing the miner's resource profile and preferences.";
  };
  outputs = {
    executionPlan = "A derivation containing a structured plan for executing the LLM tasks.";
  };
}
