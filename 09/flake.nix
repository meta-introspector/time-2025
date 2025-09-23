{
  description = "September 2025 concepts and AI context.";

  inputs = {
    day_23_concepts.url = "./23/nix_concepts_and_facts"; # Import the daily flake
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify"; # Use meta-introspector nixpkgs
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
  };

  outputs = { self, day_23_concepts, nixpkgs, flake-utils, ... } :
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      {
        packages.default = day_23_concepts.packages.${system}.default; # Expose ai-context-23 as default
        inherit (day_23_concepts.packages.${system}) number-23 is-prime-23 fact-23-oracle; # Expose individual concepts

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            bash
            nix-info
          ];
        };
      }
    );
}
