{
  description = "Nix flake for filtering CRQ lists by keyword.";

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
        # Expose a function to filter CRQs
        lib = {
          filterCrqs = crqs: keyword:
            if keyword != null then
              builtins.filter (crq: builtins.match ".*${builtins.toLower keyword}.*" (builtins.toLower crq.title) != null) crqs
            else
              crqs;
        };
      });
}
