{
  description = "A flake to generate a histogram of bag-of-words from collected flake.lock files.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    collectLocks = {
      url = "path:../001_collect_locks";
      flake = false; # Treat as a path, not a flake
    };
  };

  outputs = { self, nixpkgs, flake-utils, collectLocks }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;
      in
      {
        packages.default = pkgs.runCommand "bow-histogram"
          {
            nativeBuildInputs = [ pkgs.jq ];
            lockFileSummaries = "${collectLocks}/all-lock-file-summaries.json";
          }
          ''
            mkdir -p $out
            jq -r '.[] | .bagOfWords | to_entries[] | "\(.key) \(.value)"' "$lockFileSummaries" | \
            awk '{count[$1] += $2} END {for (word in count) print word, count[word]}' | \
            sort -k2nr > $out/bow-histogram.txt
          '';
      }
    );
}
