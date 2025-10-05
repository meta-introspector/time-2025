{
  description = "Layer 1 flake for CRQ search lattice, building on the base flake.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    base = {
      url = "../base"; # Reference the local base flake
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = { self, nixpkgs, flake-utils, base }:
    let
      system = "aarch64-linux";
      pkgs = import nixpkgs {
          inherit system;
          overlays = [];
        };
    in
    {
      packages.${system}.default = pkgs.runCommand "layer1-flake-metadata" {
        DESCRIPTION = "Layer 1 flake for CRQ search lattice.";
        meta.flakeName = "layer1";
        meta.system = system;
        meta.nixpkgsRef = nixpkgs.rev or "";
        meta.flakeUtilsRef = flake-utils.rev or "";
        baseFlakeMetadata = base.packages.${system}.default; # Inherit metadata from base flake
      } "echo 'Flake Name: $(meta.flakeName)' > $out\n echo 'Description: $(DESCRIPTION)' >> $out\n echo 'System: $(meta.system)' >> $out\n echo 'Nixpkgs Ref: $(meta.nixpkgsRef)' >> $out\n echo 'Flake-Utils Ref: $(meta.flakeUtilsRef)' >> $out\n echo 'Base Flake Metadata: $(baseFlakeMetadata)' >> $out";
    };
