{ nixCodeIndexerModule
, nGramGeneratorModule
, ...
}:

let
  common = import ../../../lib/common-imports.nix { };
  inherit (common) lib;
  inherit (common) pkgs;
  inherit (common) builtins;

  # Define the n-gram lengths we are interested in
  nGramLengths = [ 2 3 5 7 11 ];
  # A function to generate n-grams from the paths of all Nix files in the project.
  generateProjectNixPathNGrams =
    { projectRoot
    , # The root path of the project to index
      name ? "project-nix-path-ngrams"
    ,
    }:
    let
      # First, index all Nix files in the project
      nixFileIndex = nixCodeIndexerModule.indexNixFiles {
        path = projectRoot;
        name = "${name}-nix-file-index";
      };

      # Read the indexed files from the JSON output
      indexedFiles = builtins.fromJSON (builtins.readFile "${nixFileIndex}/nix-files.index.json");

      # Extract all file paths
      allNixFilePaths = lib.map (f: f.path) indexedFiles;

      # Tokenize each path and generate n-grams
      allPathNGrams = lib.flatten (lib.map
        (path: # For each file path
          let
            tokens = nGramGeneratorModule.tokenizePath path;
          in
          nGramGeneratorModule.generateNGrams { inherit tokens nGramLengths; }
        )
        allNixFilePaths);

      # Create a derivation to output the generated n-grams
      nGramOutput = pkgs.runCommand name
        {
          inherit allPathNGrams;
        }
        '''
      mkdir -p $out
      echo "${lib.strings.concatStringsSep "\n" allPathNGrams}" > $out/nix-path-ngrams.txt
      echo "Generated ${builtins.length allPathNGrams} n-grams from Nix file paths." >&2
    '';

    in
    nGramOutput;

in
{
  inherit generateProjectNixPathNGrams;
}
