#!/usr/bin/env bash

set -euo pipefail

echo "Creating Nix-related files and directories..."

# Create lib directory and common-imports.nix
mkdir -p lib
cat <<'EOF' > lib/common-imports.nix
{ pkgs ? import <nixpkgs> {}, lib ? pkgs.lib, builtins ? builtins }: { inherit pkgs lib builtins; }
EOF

# Create theory directory and Nix files within it
mkdir -p theory
cat <<'EOF' > theory/nix_code_indexer.nix
{ lib, pkgs, builtins }: {
  indexNixFiles = { path, projectRoot, name ? "nix-file-index" }:
    pkgs.runCommand name {
      inherit path projectRoot;
      __impure = true;
      nativeBuildInputs = [ pkgs.findutils pkgs.nix pkgs.gnused ];
    }
    ''
      mkdir -p $out
      echo "[" > $out/nix-files.index.json
      FIRST=true
      find "${path}" -type f -name "*.nix" -print0 | while IFS= read -r -d $'\0' file; do
          file_hash=$(nix hash file --sri "$file")
          relative_path=$(echo "$file" | sed "s|^${projectRoot}/||")
          printf '  {"path": "%s", "hash": "%s"}' "$relative_path" "$file_hash" >> $out/nix-files.index.json
        FIRST=false
      done
      echo "]" >> $out/nix-files.index.json
    '';
}
EOF

cat <<'EOF' > theory/n_gram_generator.nix
{ lib, pkgs, builtins }: {
  generateNGrams = { text, n ? 2, name ? "n-gram-output" }:
    pkgs.runCommand name {
      inherit text n;
      nativeBuildInputs = [ pkgs.gnused pkgs.gnugrep ];
    }
    ''
      echo "${text}" | sed -E 's/[^a-zA-Z0-9 ]+/ /g' | tr '[:upper:]' '[:lower:]' | \
      tr -s ' ' '\n' | grep -v '^$' | \
      awk -v n="${n}" '{ 
        for (i = 1; i <= NF - n + 1; i++) {
          line = $i;
          for (j = 1; j < n; j++) {
            line = line " " $(i + j);
          }
          print line;
        }
      }' > $out/ngrams.txt
    '';
}
EOF

cat <<'EOF' > theory/nix_2gram_indexer_step1.nix
{ lib, pkgs, builtins, nixCodeIndexerModule, nGramGeneratorModule }:
{
  generate2GramIndexStep1 = { projectRoot, name ? "step1-nix-file-index" }:
    let
      nixFilesIndex = nixCodeIndexerModule.indexNixFiles {
        path = projectRoot;
        inherit projectRoot;
      };
    in
    nixFilesIndex;
}
EOF

cat <<'EOF' > theory/nix_2gram_indexer_step2.nix
let
  pkgs = import <nixpkgs> {};
in
{ lib, pkgs, builtins, nixCodeIndexerModule, nGramGeneratorModule }:
{
  generate2GramIndexStep2 = { projectRoot, name ? "step2-indexed-files-json" }:
    let
      step1Output = nixCodeIndexerModule.indexNixFiles {
        path = projectRoot;
        inherit projectRoot;
      };
      nixFileIndex = step1Output; # nixFileIndex is defined here
      indexedFilesJsonDerivation = pkgs.runCommand "nix-files-json" {
        buildInputs = [ pkgs.nix ];
        __impure = true; # Mark as impure because its input comes from an impure derivation
      } "cat ${nixFileIndex}/nix-files.index.json > $out";
    in
    indexedFilesJsonDerivation;
}
EOF

# Create hello_world.nix
cat <<'EOF' > hello_world.nix
{ pkgs ? import <nixpkgs> {} }:

pkgs.runCommand "hello-world" {} ''
  mkdir -p $out
  echo "Hello, Nix!" > $out/hello.txt
''
EOF

# Create temp_step2_eval.nix
cat <<'EOF' > temp_step2_eval.nix
let
  common = import ./lib/common-imports.nix {};
  pkgs = common.pkgs;
  lib = common.lib;
  builtins = common.builtins;

  nixCodeIndexerModule = import ./theory/nix_code_indexer.nix { inherit lib pkgs builtins; };
  nGramGeneratorModule = import ./theory/n_gram_generator.nix { inherit lib pkgs builtins; };

  generate2GramIndexStep1Module = import ./theory/nix_2gram_indexer_step1.nix {
    inherit lib pkgs builtins nixCodeIndexerModule nGramGeneratorModule;
  };
  generate2GramIndexStep2Module = import ./theory/nix_2gram_indexer_step2.nix {
    inherit lib pkgs builtins nixCodeIndexerModule nGramGeneratorModule;
  };

  projectRoot = ./.; # Current directory as project root

  step1Output = generate2GramIndexStep1Module.generate2GramIndexStep1 {
    inherit projectRoot;
    name = "step1-nix-file-index";
  };

in
generate2GramIndexStep2Module.generate2GramIndexStep2 {
  inherit projectRoot;
  name = "step2-indexed-files-json";
}
EOF

# Create bug_repro.nix
cat <<'EOF' > bug_repro.nix
{
  description = "Minimal example to reproduce nix-build assertion failure with impure derivations.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs";
    nixpkgs.ref = "feature/CRQ-016-nixify";
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
              relative_path=$(echo "$file" | sed "s|^${projectRoot}/||")
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
EOF

# Create run_step2_build.sh
cat <<'EOF' > run_step2_build.sh
#!/usr/bin/env bash

nix-build /data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/temp_step2_eval.nix --extra-experimental-features "impure-derivations ca-derivations" > /data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/.step2.output_path 2>&1
EOF
chmod +x run_step2_build.sh

# Create dummy_project directory and test.nix
mkdir -p dummy_project
cat <<'EOF' > dummy_project/test.nix
let x = 1; in x
EOF

echo "Nix-related files and directories setup complete."