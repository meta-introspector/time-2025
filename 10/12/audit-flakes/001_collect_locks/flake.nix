{
  description = "A flake to collect all flake.lock files in a given project path. // Forced re-evaluation.";

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
                nativeBuildInputs = [ pkgs.jq ];
                lockFile = item.lockFilePath;
                NIX_FILE_PATH = item.nixFilePath;
                NIX_FILE_CONTENT = item.nixFileContent;
              }
              ''
                mkdir -p $out

                # Calculate bag of words
                BAG_OF_WORDS=$(echo -n "$NIX_FILE_CONTENT" | \
                  tr '[:upper:]' '[:lower:]' | \
                  grep -oE '\w+' | \
                  sort | \
                  uniq -c | \
                  awk '{print "\"" $2 "\":" $1}' | \
                  paste -sd, - | \
                  awk -v OFS="" 'BEGIN{print "{"};{print $0};END{print "}"}'
                )

                jq -n \
                  --arg nixFilePath "$NIX_FILE_PATH" \
                  --arg lockFilePath "$lockFile" \
                  --argjson bagOfWords "$BAG_OF_WORDS" \
                  '{nixFilePath: $nixFilePath, lockFilePath: $lockFilePath, bagOfWords: $bagOfWords, hasLockFile: true}' > $out/lock-file-info.json
              ''
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
          # Flake: 001_collect_locks

          ## Purpose

          This flake is the first step in the flake audit process. Its primary purpose is to recursively find and collect the absolute paths of all `flake.lock` files within a given project directory.

          ## Inputs

          *   `nixpkgs`: Standard Nixpkgs input.
          *   `flake-utils`: Utility functions for Nix flakes.
          *   `project`: The root path of the project to be audited. This input should be treated as a path, not a flake.

          ## Outputs

          *   `packages.*`: Individual derivations, each containing a `lock-file-info.json` for a specific `flake.lock` file found in the project. The attribute names are `lock-file-0`, `lock-file-1`, etc.
          *   `checks.allLockFilePackageNames`: A check that outputs a JSON array of the attribute names of the `packages.*` derivations (e.g., `["lock-file-0", "lock-file-1"]`), useful for debugging and verification.

          ## Usage

          To build a specific lock file package (e.g., the first one):

          ```bash
          nix build .#packages.lock-file-0
          cat ./result/lock-file-info.json
          ```

          To inspect the names of all collected lock file packages:

          ```bash
          nix build .#checks.allLockFilePackageNames
          cat ./result/names.json
          ```

          This flake is designed to be chained with subsequent flakes in the audit process.
        '';
      }
    );
}
