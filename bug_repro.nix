{
  description = "Minimal example to reproduce nix-build assertion failure with impure derivations.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
  };

  outputs = { self, nixpkgs }:
    let
      system = "aarch64-linux"; # Assuming aarch64-linux as the target system
      pkgs = nixpkgs.legacyPackages.${system};
      lib = pkgs.lib;
      builtins = builtins; # Use builtins directly

      # Minimal indexNixFiles function, similar to nix_code_indexer.nix
      indexNixFiles = {
        path, # The path to scan for .nix files
        projectRoot, # The root path to calculate relative paths against
        name ? "nix-file-index",
      }:
        pkgs.runCommand name {
          inherit path projectRoot;
          __impure = true; # Scanning the filesystem is impure
          nativeBuildInputs = [ pkgs.findutils pkgs.nix pkgs.gnused ];
        }
        ''
          echo "DEBUG: path = ${path}" >&2
          echo "DEBUG: projectRoot = ${projectRoot}" >&2
          echo "Indexing .nix files in ${path}..." >&2
          mkdir -p $out
          echo "[" > $out/nix-files.index.json
          FIRST=true
          find "${path}" -type f -name "*.nix" -print0 | while IFS= read -r -d $'\0' file; do
              file_hash=$(nix hash file --sri "$file")
              relative_path=$(echo "$file" | sed "s|^$projectRoot/||")
              printf '  {"path": "%s", "hash": "%s"}' "$relative_path" "$file_hash" >> $out/nix-files.index.json
            FIRST=false
          done
          echo "]" >> $out/nix-files.index.json
          echo "Nix files indexed in $out/nix-files.index.json" >&2
        '';

    in
    {
      packages.${system}.default = indexNixFiles {
        path = ./dummy_project;
        projectRoot = ./dummy_project;
        name = "bug-repro-index";
      };
    };
}
