{
  description = "A flake to process collected flake.lock files and generate detailed reports.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils = {
      url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
      inputs.systems.url = "github:meta-introspector/nix-systems-default-fork?ref=feature/CRQ-016-nixify";
    };
    collectLocks = {
      url = "path:../001_collect_locks"; # Input from the collect_locks flake
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    bagOfWordsGenerator = {
      url = "github:meta-introspector/time-2025?ref=feature/aimyc-003-cultivation&dir=flakes/bag-of-words-generator";
      flake = true;
    };
  };

  outputs = { self, nixpkgs, flake-utils, collectLocks, bagOfWordsGenerator }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;

        # Get the collected lock file information from the collectLocks flake
        collectedLockFiles = collectLocks.packages.${system};

        # Map over the collected lock files and process each one
        processedLockFiles = lib.listToAttrs (lib.imap0
          (index: name:
            let
              itemPath = collectedLockFiles.${name}; # This is the path to the JSON output from collectLocks
              itemContent = builtins.fromJSON (builtins.readFile itemPath + "/lock-file-info.json");
            in
            lib.nameValuePair name (pkgs.runCommand name
              {
                nativeBuildInputs = [ pkgs.jq pkgs.nix ];
                lockFile = itemContent.lockFilePath;
                NIX_FILE_PATH = itemContent.nixFilePath;
                NIX_FILE_CONTENT = itemContent.nixFileContent;
                BAG_OF_WORDS_GENERATOR_LIB_PATH = bagOfWordsGenerator.lib.${system}; # Pass the lib output of the fetched input
              }
              (builtins.readFile ./process_lock_file.sh)
            )
          )
          (builtins.attrNames collectedLockFiles)
        );
      in
      {
        packages = processedLockFiles // {
          default = pkgs.runCommand "lock-file-summaries"
            {
              nativeBuildInputs = [ pkgs.jq ];
              lockFileOutputs = builtins.toJSON (builtins.map (name: "${processedLockFiles.${name}.outPath}/lock-file-info.json") (builtins.attrNames processedLockFiles));
            }
            ''
              mkdir -p $out
              jq -s '.[].content | fromjson' $(echo $lockFileOutputs | jq -r '.[]') > $out/all-lock-file-summaries.json
            '';
        };

        docs.usage = pkgs.writeText "usage.md" ''
          # 002_process_locks Flake
        
          ## Description
        
          This Nix flake processes the output of the `001_collect_locks` flake. For each collected `flake.nix` and `flake.lock` pair, it generates a detailed `lock-file-info.json` report, including a bag-of-words representation of the `flake.nix` content. Finally, it aggregates all individual reports into a single `all-lock-file-summaries.json` file.
        
          ## Inputs
        
          -   `nixpkgs`: Standard Nixpkgs input.
          -   `flake-utils`: Utility functions for Nix flakes.
          -   `collectLocks`: The output of the `001_collect_locks` flake, providing paths to `flake.nix` and `flake.lock` files.
          -   `bagOfWordsGenerator`: A reference to the `bag-of-words-generator` flake, used to generate bag-of-words reports for `flake.nix` files.
        
          ## Outputs
        
          -   `packages.*`: Individual derivations, each containing a `lock-file-info.json` for a specific `flake.lock` file. The attribute names correspond to those from `collectLocks` (e.g., `lock-file-0`).
          -   `packages.default`: An aggregation of all `lock-file-info.json` outputs into a single `all-lock-file-summaries.json` file.
        
          ## Usage Example (within another Flake)
        
          ```nix
          let
            processLocks = inputs.process_locks_flake; # Assuming process_locks_flake is an input
            allSummaries = processLocks.packages.default; # Path to all-lock-file-summaries.json
            firstLockFileInfo = processLocks.packages.lock-file-0; # Path to lock-file-info.json for the first lock file
          in
            # ... use allSummaries or firstLockFileInfo ...
          ```
        
          ## Documentation Output
        
          To view the documentation for this flake, you can build its `docs.usage` output:
        
          ```bash
          nix build 10/12/audit-flakes/002_process_locks/.#docs.aarch64-linux.usage
          cat ./result
          ```
        '';
      }
    );
}
