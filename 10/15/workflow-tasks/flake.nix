{
  description = "A virtual flake for creating workflow tasks.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    llmGeneratorFlake.url = "github:meta-introspector/time-2025?ref=feature/aimyc-003-cultivation&dir=10/14";
  };

  outputs = { self, nixpkgs, flake-utils, llmGeneratorFlake }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;

        # Read task definitions from the 'tasks' subdirectory
        taskDefinitions = lib.mapAttrs'
          (name: path: {
            name = lib.removeSuffix ".nix" name;
            value = import path { inherit pkgs lib builtins llmGeneratorFlake; };
          })
          (lib.filterAttrs (name: value: lib.hasSuffix ".nix" name) (builtins.readDir ./tasks));
      in
      {
        packages = lib.mapAttrs
          (name: task:
            # Check if the imported task is a function
            if lib.isFunction task then
              # If it's a function, expose the function directly
              task
            else
              # If it's an attribute set, create a runCommand derivation as before
              pkgs.runCommand "${name}-task"
                {
                  meta = task;
                  taskScript = if task ? script
                               then task.script
                               else pkgs.writeScript "default-task-script" ''
                                 echo "Executing task: ${task.name}"
                                 echo "Description: ${task.description}"
                               '';
                } ''
                mkdir -p $out/bin
                cp $taskScript $out/bin/run-task
                chmod +x $out/bin/run-task
              '')
          taskDefinitions;
        defaultPackage = pkgs.linkFarm "workflow-tasks" (
          lib.mapAttrsToList (name: value: {
            inherit name;
            path = value;
          }) self.packages.${system}
                    );
        
                    docs.md = pkgs.writeText "workflow-tasks-docs.md" ''
                      # Workflow Tasks Virtual Flake
        
                      ## Description
        
                      This flake acts as a "virtual flake" factory, dynamically generating individual task derivations for each step of a defined workflow. It reads task definitions from the `./tasks` subdirectory and creates runnable packages for each.
        
                      ## Inputs
        
                      -   `nixpkgs`: Standard Nixpkgs.
                      -   `flake-utils`: Utility functions for Nix flakes.
        
                      ## Outputs
        
                      ### `packages.${system}.<task-name>`
        
                      For each `.nix` file found in the `./tasks` subdirectory, this flake generates a package named after the task. Each package is a derivation that, when built, provides a simple script to "execute" or describe the task.
        
                      ### `defaultPackage`
        
                      A `linkFarm` that aggregates all individual task packages, providing a convenient way to access all workflow tasks.
                    '';

                    bootstrap = pkgs.runCommand "workflow-tasks-bootstrap" {
                      allPackages = self.packages.${system};
                      flakeDocs = self.docs.md;
                      defaultPkg = self.defaultPackage.${system};
                    } ''
                      echo "Successfully built all workflow tasks, default package, and documentation." > $out
                    '';
                  }
                );
            }
