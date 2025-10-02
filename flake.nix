{
  description = "Top-level flake for the streamofrandom/2025 project, orchestrating single-concept flakes.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";

    # Reference the 09/flake.nix as a submodule for now
    # This will be broken down into more granular flakes later
    streamofrandom09.url = "path:./09";
  };

  outputs = { self, nixpkgs, flake-utils, streamofrandom09, ... }:
    let
      system = "aarch64-linux"; # Explicitly define system for debugging
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      devShell = streamofrandom09.outputs.${system}.devShells.default;
    };
}