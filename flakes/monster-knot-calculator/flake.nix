
{
  description = "Nix flake to calculate Monster Knot similarity";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11"; # Using a stable nixpkgs branch
    narSimilaritySearch = {
      url = "github:meta-introspector/nar-similarity-search?ref=feature/CRQ-016-nixify"; # Assuming this repo and branch
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, narSimilaritySearch }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      devShells = forAllSystems (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            # You might need to add overlays here if narSimilaritySearch requires specific packages
          };
        in
        {
          default = pkgs.mkShell {
            buildInputs = [
              # Add any tools needed in the shell, e.g., nix-prefetch-git
            ];
            shellHook = ''
              echo "Welcome to the Monster Knot Calculator shell!"
              echo "To calculate the Monster Knot for a simple flake, run:"
              echo "  nix eval --raw --expr 'narSimilaritySearch.lib.${system}.calculateMonsterKnot (pkgs.path + "/simple-flake")'"
              echo "Or, to get the value directly:"
              echo "  export MONSTER_KNOT_VALUE=$(nix eval --raw --expr 'narSimilaritySearch.lib.${system}.calculateMonsterKnot (pkgs.path + "/simple-flake")')"
              echo "  echo $MONSTER_KNOT_VALUE"
            '';
          };
        });

      # You could also expose this as a package if you want to build it
      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs {
            inherit system;
          };
        in
        {
          monsterKnotValue = pkgs.writeText "monster-knot-value" (
            narSimilaritySearch.lib.${system}.calculateMonsterKnot (pkgs.path + "/simple-flake")
          );
        }
      );
    };
}
