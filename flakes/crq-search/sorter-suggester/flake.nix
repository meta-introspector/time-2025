{
  description = "Nix flake for sorting CRQ lists and providing top N suggestions.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        # Expose a function to sort and suggest CRQs
        lib = {
          sortAndSuggestCrqs = crqs: numSuggestions:
            let
              # Sort by CRQ ID (descending for latest)
              sortedCrqs = pkgs.lib.sort (a: b: builtins.compareVersion a.id b.id > 0) crqs;

              # Get the latest N suggestions
              suggestions = pkgs.lib.take numSuggestions sortedCrqs;
            in
            suggestions;
        };
      });
}
