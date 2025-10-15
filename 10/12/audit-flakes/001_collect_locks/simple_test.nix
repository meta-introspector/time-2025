{ projectPath ? /data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025 }:

let
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
          in
          if hasLockFile
          then "Found flake.nix: ${nixFilePath}, lockFile: ${lockFilePath}"
          else "Found flake.nix: ${nixFilePath}, NO lockFile"
        )
        currentNixFiles;

      # Recursively search subdirectories
      subDirs = builtins.filter (name: dirContents.${name} == "directory") (builtins.attrNames dirContents);
      recursiveNixFileInfos = builtins.concatLists (builtins.map (name: findAllFlakeLocks (pathValue + "/${name}")) subDirs);
    in
    currentNixFileInfos ++ recursiveNixFileInfos;

in

findAllFlakeLocks projectPath
