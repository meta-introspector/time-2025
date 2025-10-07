{ pkgs ? import <nixpkgs> {} }:

let
  # Import the list of task attribute sets
  taskAttributeSets = import ./generate-derivations.nix { inherit (pkgs) lib; };

  # Map each task attribute set to a string representation
  taskStrings = pkgs.lib.map (task: task.name + ": " + task.gemini_prompt) taskAttributeSets;

  # Convert the list of strings to a single string with newlines
  tasksString = pkgs.lib.concatStringsSep "\n" taskStrings;

  # Write the tasks string to a temporary file
  tasksFile = pkgs.writeText "tasks-list.txt" tasksString;
in
pkgs.runCommand "generated-tasks" {} ''
  cat ${tasksFile} > "$out"
''
