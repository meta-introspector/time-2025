
{
  description = "Nix flake for comprehensive CRQ search functionality.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    crqReader = {
      url = "github:meta-introspector/time-2025?ref=feature/foaf&dir=flakes/crq-search/reader";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    crqFilter = {
      url = "github:meta-introspector/time-2025?ref=feature/foaf&dir=flakes/crq-search/filter";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    crqSorterSuggester = {
      url = "github:meta-introspector/time-2025?ref=feature/foaf&dir=flakes/crq-search/sorter-suggester";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = { self, nixpkgs, flake-utils, crqReader, crqFilter, crqSorterSuggester }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        readCrqs = crqReader.lib.${system}.readCrqs;
        filterCrqs = crqFilter.lib.${system}.filterCrqs;
        sortAndSuggestCrqs = crqSorterSuggester.lib.${system}.sortAndSuggestCrqs;
      in
      {
        # Expose the main CRQ search function
        lib = {
          searchCrqs = crqDir: keyword: numSuggestions: # numSuggestions is new, to make it configurable
            let
              allParsedCrqs = readCrqs crqDir;
              filtered = filterCrqs allParsedCrqs keyword;
              suggestions = sortAndSuggestCrqs filtered numSuggestions;
            in
            suggestions;
        };

        # Optionally, an app to demonstrate the search
        apps.default = flake-utils.lib.mkApp {
          drv = pkgs.writeShellScriptBin "crq-search-app" ''
            # Example usage: nix run .#crq-search-app -- /path/to/crqs "keyword" 3
            if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
              echo "Usage: $0 <crq-directory> <keyword> <num-suggestions>"
              exit 1
            fi
            ${pkgs.nix-eval-js}/bin/nix-eval-js --expr '(
              let
                flake = builtins.getFlake (toString ./.);
                system = builtins.currentSystem;
                searchCrqs = flake.outputs.lib.${system}.searchCrqs;
              in
              builtins.toJSON (searchCrqs "$1" "$2" (builtins.fromJSON "$3"))
            )'
          '';
        };
      });
}
