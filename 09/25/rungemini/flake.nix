{
  description = "Run gemini-cli with Nix";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    geminiCli.url = "github:meta-introspector/gemini-cli?ref=feature/CRQ-016-nixify-2025-10-06";
  };

  outputs = { self, nixpkgs, geminiCli, ... }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ]; # Assuming these are the relevant systems
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          # Override the gemini-cli package to update npmDepsHash
          geminiCliOverridden = geminiCli.packages.${system}.default.overrideAttrs (oldAttrs: {
            npmDepsHash = "sha256-uX9M3xnsMnjwRqjl/sDWb+A8Km6f5du91SoDRH4zY24="; # The correct hash from previous runs
          });
        in
        {
          default = geminiCliOverridden;
        });

      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          # Override the gemini-cli package for the devShell as well
          geminiCliOverridden = geminiCli.packages.${system}.default.overrideAttrs (oldAttrs: {
            npmDepsHash = "sha256-uX9M3xnsMnjwRqjl/sDWb+A8Km6f5du91SoDRH4zY24="; # The correct hash from previous runs
          });
        in
        {
          default = pkgs.mkShell {
            packages = [
              geminiCliOverridden
            ];
          };
        });
    };
}
