{ nixpkgs }:

let
  flake-utils = import (builtins.fetchTarball "https://github.com/meta-introspector/flake-utils/archive/feature/CRQ-016-nixify.tar.gz") { };
  lib = flake-utils.lib;
  pkgs = nixpkgs.legacyPackages.aarch64-linux; # Hardcode system for simplicity

in

lib.eachDefaultSystem (system:
let
  # Dummy allLockFiles for testing
  allLockFiles = [
    { nixFilePath = "/path/to/flake1.nix"; lockFilePath = "/path/to/flake1.lock"; }
    { nixFilePath = "/path/to/flake2.nix"; lockFilePath = "/path/to/flake2.lock"; }
  ];

  lockFilePackages = lib.listToAttrs (lib.imap0
    (index: item:
      let
        name = "lock-file-${toString index}";
      in
      lib.nameValuePair name (pkgs.runCommand name
        {
          # Simplified attributes for testing
          NIX_FILE_PATH = item.nixFilePath;
          LOCK_FILE_PATH = item.lockFilePath;
        }
        "echo '{\"nixFilePath\": \"$NIX_FILE_PATH\", \"lockFilePath\": \"$LOCK_FILE_PATH\"}' > $out/lock-file-info.json"
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
        lockFileOutputs = builtins.toJSON (builtins.map (name: "${lockFilePackages.${name}.outPath}/lock-file-info.json") (builtins.attrNames lockFilePackages));
      }
      ''
        mkdir -p $out
        jq -s '.[].content | fromjson' $(echo $lockFileOutputs | jq -r '.[]') > $out/all-lock-file-summaries.json
      '';
  };
}
)
