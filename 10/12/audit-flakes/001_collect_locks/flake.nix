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
    bagOfWordsGenerator = {
      #url = "git+file:///data/data/com.termux.nix/files/home/git/time-2025?ref=feature/aimyc-002-sample-extraction&dir=flakes/bag-of-words-generator";
      url = "github:meta-introspector/time-2025?ref=feature/aimyc-003-cultivation&dir=flakes/bag-of-words-generator";
      flake = true;
    };
  };

  outputs = { self, nixpkgs, flake-utils, project, bagOfWordsGenerator }:
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
                nativeBuildInputs = [ pkgs.jq pkgs.nix ];
                lockFile = item.lockFilePath;
                NIX_FILE_PATH = item.nixFilePath;
                NIX_FILE_CONTENT = item.nixFileContent;
                BAG_OF_WORDS_GENERATOR_PATH = bagOfWordsGenerator; # Pass the path to the fetched input
              }
              (builtins.readFile ./flake.sh)
            )
          )
          allLockFiles
        );
      in
      {
        packages = lockFilePackages // {
          default = pkgs.runCommand "lock-file-summaries"
            {
              nativeBuildInputs = [ pkgs.jq ];
              lockFileOutputs = builtins.toJSON (builtins.map (name: "${lockFilePackages.${name}}/lock-file-info.json") (builtins.attrNames lockFilePackages));
            }
            ''
              mkdir -p $out
              jq -s '.[].content | fromjson' $(echo $lockFileOutputs | jq -r '.[]') > $out/all-lock-file-summaries.json
            '';
        };

        checks.allLockFilePackageNames = pkgs.runCommand "all-lock-file-package-names"
          {
            nativeBuildInputs = [ pkgs.jq ];
            lockFileNames = builtins.toJSON (builtins.attrNames lockFilePackages);
          }
          ''
            mkdir -p $out
            echo "$lockFileNames" > $out/names.json
          '';

        docs.usage = pkgs.writeText "usage.md" ''
          # 001_collect_locks Flake
        
          ## Description
        
          This Nix flake is the first step in the flake audit process. Its primary purpose is to recursively find and collect information about all `flake.lock` files within a given project directory. For each `flake.lock` file found, it generates a structured JSON report (`lock-file-info.json`) that includes metadata about the `flake.nix` and `flake.lock` files, as well as a bag-of-words representation of the `flake.nix` content.
        
          ## Inputs
        
          -   `nixpkgs`: Standard Nixpkgs input.
          -   `flake-utils`: Utility functions for Nix flakes.
          -   `project`: The root path of the project to be audited. This input should be treated as a path, not a flake.
          -   `bagOfWordsGenerator`: A reference to the `bag-of-words-generator` flake, used to generate bag-of-words reports for `flake.nix` files.
        
          ## Outputs
        
          -   `packages.*`: Individual derivations, each containing a `lock-file-info.json` for a specific `flake.lock` file found in the project. The attribute names are `lock-file-0`, `lock-file-1`, etc.
          -   `packages.default`: An aggregation of all `lock-file-info.json` outputs into a single `all-lock-file-summaries.json` file.
          -   `checks.allLockFilePackageNames`: A check that outputs a JSON array of the attribute names of the `packages.*` derivations (e.g., `["lock-file-0", "lock-file-1"]`), useful for debugging and verification.
          -   `test_flake_sh`: A path to the `test_flake_sh.sh` script, used for testing the `flake.sh` script.
          -   `run_flake_sh_test_env`: A path to the `run_flake_sh_test_env.sh` script, used for running the `flake.sh` script in a test environment.
        
          ## `flake.sh` Script
        
          This shell script is executed by the `runCommand` for each `lock-file-N` derivation. It orchestrates the collection of information and the generation of the `lock-file-info.json`.
        
          ### Expectations (Environment Variables)
        
          The `flake.sh` script expects the following environment variables to be set by the Nix build environment:
        
          -   `out`: The output path for the derivation.
          -   `NIX_FILE_PATH`: The absolute path to the `flake.nix` file associated with the current `flake.lock`.
          -   `lockFile`: The absolute path to the `flake.lock` file being processed.
          -   `BAG_OF_WORDS_GENERATOR_PATH`: The absolute path to the fetched `bag-of-words-generator` flake.
        
          ### Internal Logic
        
          1.  **Get System:** Dynamically determines the current system (e.g., `aarch64-linux`) using `nix eval 'builtins.currentSystem'`.
          2.  **Generate Bag-of-Words:** Calls the `generateBagOfWords` function from the `bagOfWordsGenerator` flake using `nix build`. It passes `NIX_FILE_PATH` as the `flakePath` argument to this function. The resulting `report.json` is captured.
          3.  **Generate `lock-file-info.json`:** Uses `jq` to combine `NIX_FILE_PATH`, `lockFile`, and the generated bag-of-words into a structured JSON object, which is then written to `$out/lock-file-info.json`.
        
          ## `lock-file-info.json` Structure
        
          This JSON file contains detailed information about a single `flake.lock` file and its corresponding `flake.nix`.
        
          ```json
          {
            "nixFilePath": "/absolute/path/to/flake.nix",
            "lockFilePath": "/absolute/path/to/flake.lock",
            "bagOfWords": {
              "word1": count1,
              "word2": count2,
              ...
            }
          }
          ```
        
          ## Usage Example (within another Flake)
        
          To use the output of this flake in another flake, you would typically access the `packages.default` attribute to get the aggregated summary, or individual `packages.lock-file-N` attributes for specific lock file information.
        
          ```nix
          let
            collectLocks = inputs.collect_locks_flake; # Assuming collect_locks_flake is an input
            allSummaries = collectLocks.packages.default; # Path to all-lock-file-summaries.json
            firstLockFileInfo = collectLocks.packages.lock-file-0; # Path to lock-file-info.json for the first lock file
          in
            # ... use allSummaries or firstLockFileInfo ...
          ```
        
          ## Testing
        
          To verify the functionality of this flake, you can run its associated test flake. The test flake executes the `flake.sh` script in a simulated Nix build environment and checks its output.
        
          ```bash
          nix flake check 10/12/audit-flakes/001_collect_locks/test_flake.nix
          ```
        
          If the check passes, it means the `flake.sh` script executed successfully and produced the expected `lock-file-info.json` output. The output of the test will be printed to the console during the check process.
        
          ## Documentation Output
        
          To view the documentation for this flake, you can build its `docs.usage` output:
        
          ```bash
          nix build 10/12/audit-flakes/001_collect_locks/.#docs.aarch64-linux.usage
          cat ./result
          ```
        '';

        test_flake_sh = ./test_flake_sh.sh;
        run_flake_sh_test_env = ./run_flake_sh_test_env.sh;
        docs.md = pkgs.writeText "001-collect-locks-docs.md" (builtins.readFile ./docs/001_collect_locks.md);

        checks.proof = pkgs.runCommand "001-collect-locks-proof"
          {
            nativeBuildInputs = [ pkgs.jq ];
            allLockFileSummaries = self.packages.${system}.default; # Reference to the aggregated output
          } ''
          echo "Verifying all-lock-file-summaries.json structure..."
          # Ensure the aggregated JSON is valid
          jq . "$allLockFileSummaries/all-lock-file-summaries.json"
          # Further checks can be added here, e.g., checking for specific fields
          echo "Proof successful: all-lock-file-summaries.json is valid JSON."
        '';
      }
    );
}
