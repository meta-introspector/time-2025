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

        # Function to recursively find all flake.lock files
        findAllFlakeLocks = pathValue:
          let
            # Read directory contents
            dirContents = builtins.readDir pathValue;
            # Filter for flake.lock files directly in this directory
            currentLockFiles = builtins.filter (name: name == "flake.lock" && dirContents.${name} == "regular") (builtins.attrNames dirContents);
            currentLockFilePaths = builtins.map (name: pathValue + "/${name}") currentLockFiles;

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
      }
    );
}
