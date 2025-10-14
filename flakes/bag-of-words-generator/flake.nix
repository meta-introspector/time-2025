{
  description = "Nix flake for generating bag-of-words from a flake.nix file.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    bagOfWordsScript = {
      url = "path:../../scripts/generate_flake_bag_of_words.sh";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, bagOfWordsScript }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        lib = {
          generateBagOfWords = flakePath:
            pkgs.runCommandLocal "bag-of-words-report"
              {
                nativeBuildInputs = [ pkgs.bash pkgs.coreutils pkgs.gnugrep pkgs.gnused pkgs.gawk pkgs.jq ];
                flakeFile = flakePath;
                script = bagOfWordsScript;
              } ''
              mkdir -p $out
              "$script" "$flakeFile" > $out/report.json
            '';
        };
      });
}
