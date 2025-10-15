{
  description = "A flake to collect all flake.lock files in a given project path. // Forced re-evaluation.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils = {
      url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
      inputs.systems.url = "github:meta-introspector/nix-systems-default-fork?ref=feature/CRQ-016-nixify";
    };
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

        # Function to recursively find all flake.nix files and check for corresponding flake.lock files
        findAllFlakeLocks = pathValue:
          let
            # Read directory contents
            dirContents = builtins.readDir pathValue;

            # Filter for flake.nix files directly in this directory
            currentNixFiles = builtins.filter (name: name == "flake.nix" && dirContents.${name} == "regular") (builtins.attrNames dirContents);

            # For each flake.nix file, check for a corresponding flake.lock
            currentNixFileInfos = builtins.map
              (name:
                let
                  nixFilePath = pathValue + "/${name}";
                  lockFilePath = pathValue + "/flake.lock";
                  hasLockFile = builtins.pathExists lockFilePath;
                  nixFileContent = builtins.readFile nixFilePath; # Read content here
                in
                { inherit nixFilePath lockFilePath nixFileContent hasLockFile; }
              )
              currentNixFiles;

            # Recursively search subdirectories
            subDirs = builtins.filter (name: dirContents.${name} == "directory") (builtins.attrNames dirContents);
            recursiveNixFileInfos = builtins.concatLists (builtins.map (name: findAllFlakeLocks (pathValue + "/${name}")) subDirs);
          in
          currentNixFileInfos ++ recursiveNixFileInfos;

        allLockFiles = findAllFlakeLocks project;

        lockFilePackages = lib.listToAttrs (lib.imap0
          (index: item:
            let
              name = "lock-file-${toString index}";
              lockFileContent = builtins.readFile item.lockFilePath;
            in
            lib.nameValuePair name (pkgs.runCommand name
              {
                nativeBuildInputs = [ pkgs.jq ]; # Add jq to nativeBuildInputs
                generate_lock_info_jq = ../scripts/jq/generate_lock_info.jq; # Add the jq script as a build input
                # The output is a JSON file with the collected info
              }
              ''
                mkdir -p $out
                jq -n \
                  --arg nixFilePath "${item.nixFilePath}" \
                  --arg lockFilePath "${item.lockFilePath}" \
                  --argjson nixFileContent "$(jq -Rs . <<< "${item.nixFileContent}")" \
                  -f "$generate_lock_info_jq" | jq . > $out/lock-file-info.json
              ''
            )
          )
          allLockFiles
        );
      in
      {
        packages = lockFilePackages;

        docs.usage = pkgs.writeText "usage.md" ''
          # 001_collect_locks Flake
        
          ## Description
        
          This Nix flake is the first step in the flake audit process. Its primary purpose is to recursively find and collect information about all `flake.lock` files within a given project directory.
        
          ## Inputs
        
          -   `nixpkgs`: Standard Nixpkgs input.
          -   `flake-utils`: Utility functions for Nix flakes.
          -   `project`: The root path of the project to be audited. This input should be treated as a path, not a flake.
        
          ## Outputs
        
          -   `packages.*`: Individual derivations, each containing a JSON file with `nixFilePath`, `lockFilePath`, and `nixFileContent` for a specific `flake.lock` file found in the project. The attribute names are `lock-file-0`, `lock-file-1`, etc.
        
          ## Usage Example (within another Flake)
        
          To use the output of this flake in another flake, you would typically access individual `packages.lock-file-N` attributes for specific lock file information.
        
          ```nix
          let
            collectLocks = inputs.collect_locks_flake; # Assuming collect_locks_flake is an input
            firstLockFileInfo = collectLocks.packages.lock-file-0; # Path to lock-file-info.json for the first lock file
          in
            # ... use firstLockFileInfo ...
          ```
        
          ## Documentation Output
        
          To view the documentation for this flake, you can build its `docs.usage` output:
        
          ```bash
          nix build 10/12/audit-flakes/001_collect_locks/.#docs.aarch64-linux.usage
          cat ./result
          ```
        '';
      }
    );
}
