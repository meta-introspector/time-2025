{ pkgs, lib, ... }:

let
  taskMdContent = builtins.readFile ./09/18/task.md;
in
''
  Please read the following task description and follow its instructions to simulate the next step of the top-level orchestrator.nix.
  The task is:
  ${taskMdContent}

  Your output should be a JSON representation of the new global state after this simulated step, including the chosen task and its execution result. Focus on how the orchestrator would leverage the provided context to make decisions and transition the system to the next state.
''
