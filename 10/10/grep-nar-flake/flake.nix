{
  description = "A flake to grep for 'nar' in specified file types.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        # Define the absolute root directory for the grep search
        # This needs to be the absolute path to the project root
        searchRoot = "/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/";

        # Define the file types to include in the grep search
        includePatterns = [
          "*.nix"
          "*.sh"
          "*Makefile*"
          "*.md"
        ];

        # Construct the grep include arguments
        grepIncludes = pkgs.lib.concatStringsSep " " (pkgs.lib.map (p: "--include='${p}'") includePatterns);

      in
      {
        packages.default = pkgs.runCommand "nar-grep-results"
          {
            nativeBuildInputs = [ pkgs.gnugrep ];
          } ''
          grep -r ${grepIncludes} "nar" ${searchRoot} > $out
        '';
      });
}
