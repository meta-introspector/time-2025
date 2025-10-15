{ lib
, tasks
, # A list of llmCallDescription objects
  prioritizationStrategy ? "alphabetical"
, # Placeholder
  groupingStrategy ? "single-block"
, # Placeholder
}:

let
  # Apply prioritization (simplified: just sort alphabetically by prompt)
  prioritizedTasks = lib.sort
    (
      a: b: lib.lessThan a.prompt b.prompt
    )
    tasks;

  # Group tasks into blocks (simplified: all tasks in one block)
  workpoolBlocks = [
    {
      blockId = "initial-workpool-block";
      tasks = prioritizedTasks;
    }
  ];

in
{
  type = "llmWorkpool";
  inherit tasks prioritizationStrategy groupingStrategy workpoolBlocks;
  description = "A workpool of prioritized and grouped LLM tasks.";
}
