{ lib, ... }:

let
  tasks = import ./lib/task-generator.nix { inherit lib; };

in
lib.map (task: task.name + ": " + task.gemini_prompt) tasks
