{
  description = "A flake to collect all flake.lock files in a given project path.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    project = {
      # The project to audit, typically the root of the repository
      url = "path:../.."; # Points to the streamofrandom 2025 root
      flake = false; # Treat as a path, not a flake
    };
  };

  outputs = { self, nixpkgs, flake-utils, project }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;

        # Function to recursively find all flake.lock files and their corresponding flake.nix files
        findAllFlakeLocks = pathValue:
          let
            # Read directory contents
            dirContents = builtins.readDir pathValue;
            # Filter for flake.lock files directly in this directory
            currentLockFiles = builtins.filter (name: name == "flake.lock" && dirContents.${name} == "regular") (builtins.attrNames dirContents);
            currentLockFilePaths = builtins.map
              (name: {
                lockFilePath = pathValue + "/${name}";
                nixFilePath = pathValue + "/flake.nix"; # Assuming flake.nix is in the same directory
              })
              currentLockFiles;

            # Recursively search subdirectories
            subDirs = builtins.filter (name: dirContents.${name} == "directory") (builtins.attrNames dirContents);
            recursiveLockFiles = builtins.concatLists (builtins.map (name: findAllFlakeLocks (pathValue + "/${name}")) subDirs);
          in
          currentLockFilePaths ++ recursiveLockFiles;

        allLockFiles = findAllFlakeLocks project;
      in
      {
        packages.default = pkgs.writeText "all-flake-locks.json" (builtins.toJSON allLockFiles);
        # For debugging, expose the list of files as a check
        checks.allFlakeLocks = pkgs.runCommand "all-flake-locks-check"
          {
            inherit allLockFiles;
          } "echo \"${builtins.toJSON allLockFiles}\" > $out";

        docs.usage = pkgs.writeText "usage.md" ''
          # Flake: 001_collect_locks

          ## Purpose

          This flake is the first step in the flake audit process. Its primary purpose is to recursively find and collect the absolute paths of all `flake.lock` files within a given project directory.

          ## Inputs

          *   `nixpkgs`: Standard Nixpkgs input.
          *   `flake-utils`: Utility functions for Nix flakes.
          *   `project`: The root path of the project to be audited. This input should be treated as a path, not a flake.

          ## Outputs

          *   `packages.default`: A derivation containing a JSON file (`all-flake-locks.json`) which is a list of absolute paths to all found `flake.lock` files.
          *   `checks.allFlakeLocks`: A check that outputs the same JSON list, useful for debugging and verification.

          ## Usage

          To build the default package (the JSON file containing the list of `flake.lock` paths):

          ```bash
          nix build .#default
          ```

          To inspect the list of collected `flake.lock` files (for debugging):

          ```bash
          nix build .#checks.allFlakeLocks
          cat ./result
          ```

          This flake is designed to be chained with subsequent flakes in the audit process.
        '';
      }
    );
}
