{
  description = "September 2025 concepts and AI context.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    day_23_concepts.url = "./23/nix_concepts_and_facts"; # Import the daily flake
  };

  outputs = { self, nixpkgs, day_23_concepts } :
    let
      pkgs = import nixpkgs {
        system = builtins.currentSystem;
      };
    in
    {
      packages.default = day_23_concepts.packages.default; # Expose ai-context-23 as default
      inherit (day_23_concepts.packages.${builtins.currentSystem}) number-23 is-prime-23 fact-23-oracle; # Expose individual concepts
    };
}
