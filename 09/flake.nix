{
  description = "September 2025 concepts and AI context.";

  inputs = {
    day_23_concepts.url = "./23/nix_concepts_and_facts"; # Import the daily flake
  };

  outputs = { self, day_23_concepts, ... } : # Removed nixpkgs from direct inputs, assuming it's passed from parent
    let
      pkgs = import self.inputs.nixpkgs { # Access nixpkgs from self.inputs
        system = builtins.currentSystem;
      };
    in
    {
      packages.default = day_23_concepts.packages.default; # Expose ai-context-23 as default
      inherit (day_23_concepts.packages.${builtins.currentSystem}) number-23 is-prime-23 fact-23-oracle; # Expose individual concepts
    };
}
