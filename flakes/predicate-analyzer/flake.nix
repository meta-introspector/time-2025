{
  description = "A flake for generating predicates and analyzing Nix files";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify"; # Use the project's canonical nixpkgs fork
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";

    fileIndexer = {
      url = "github:meta-introspector/time-2025?ref=feature/CRQ-016-nixify&dir=10/11/file-indexer"; # Adjust ref as needed
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = { self, nixpkgs, flake-utils, fileIndexer, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (pkgs) lib;

        # Use the fileIndexer flake to get a list of all files in the main project
        allFilesListDerivation = fileIndexer.lib.${system}.indexAllFiles {
          path = ../../.; # The main project's source
          name = "main-project-all-files";
        };

        # Filter the list of all files to get only .nix files
        nixFilesListDerivation = pkgs.runCommand "nix-files-list" {
          allFiles = allFilesListDerivation;
          nativeBuildInputs = [ pkgs.gnugrep ]; # For filtering
        } ''
          mkdir -p $out
          grep ".nix$" "${allFiles}" > $out/nix-files.txt
        '';

        # The path to the generated nix.txt file within the derivation's output
        nixFilesListPath = "${nixFilesListDerivation}/nix-files.txt";

        tempPredicateGenerator = import ./lib/temp_predicate_generator.nix;
        predicateAnalysis = tempPredicateGenerator {
          inherit pkgs lib;
          inherit nixFilesListPath;
        };

      in
      {
        packages.default = pkgs.symlinkJoin {
          name = "predicate-analysis-results";
          paths = [
            pkgs.writeText "predicate-frequencies.json" (builtins.toJSON predicateAnalysis.predicateFrequencies)
            pkgs.writeText "sorted-predicates.json" (builtins.toJSON predicateAnalysis.sortedPredicates)
            pkgs.writeText "predicate-matrix.json" (builtins.toJSON predicateAnalysis.predicateMatrix)
          ];
        };

        # Expose individual analysis results
        predicateFrequencies = pkgs.writeText "predicate-frequencies.json" (builtins.toJSON predicateAnalysis.predicateFrequencies);
        sortedPredicates = pkgs.writeText "sorted-predicates.json" (builtins.toJSON predicateAnalysis.sortedPredicates);
        predicateMatrix = pkgs.writeText "predicate-matrix.json" (builtins.toJSON predicateAnalysis.predicateMatrix);

        nixFileList = nixFilesListDerivation; # Expose the filtered nix file list
        allFilesList = allFilesListDerivation; # Expose the all files list

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            nix
            nixpkgs-fmt
            statix
          ];
        };
      }
    );
}