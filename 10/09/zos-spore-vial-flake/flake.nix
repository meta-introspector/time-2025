{
  description = "A flake to package the ZOS Spore Flake output into a NAR vial.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    zosSporeFlake = {
      url = "path:../zos-spore-flake"; # Reference the ZOS Spore Flake
      flake = true;
    };
    narBridgeFlake = {
      url = "path:../hackathon/nar-bridge-flake"; # Reference our nar-bridge-flake
      flake = true;
    };
  };

  outputs = { self, nixpkgs, zosSporeFlake, narBridgeFlake }:
    let
      pkgs = nixpkgs.legacyPackages.aarch64-linux;

      # Get the default output (compressed ZOS elements) from the ZOS Spore Flake
      zosSporeOutput = zosSporeFlake.packages.aarch64-linux.default;

      # Create a NAR archive (the "vial") from the ZOS Spore Flake's output
      zosSporeVial = narBridgeFlake.lib.createNar {
        name = "zos-spore-vial";
        path = zosSporeOutput;
      };
    in
    {
      packages.aarch64-linux.default = zosSporeVial;
    };
}