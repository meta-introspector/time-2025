{
  description = "A clean room environment for cultivating the ZOS Spore Vial.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    zosSporeVialFlake = {
      url = "github:meta-introspector/time-2025?ref=feature/lattice-30030-homedir&dir=10/09/zos-spore-vial-flake";
      flake = true;
    };
    narBridgeFlake = {
      url = "github:meta-introspector/time-2025?ref=feature/lattice-30030-homedir&dir=10/09/hackathon/nar-bridge-flake";
      flake = true;
    };
  };

  outputs = { self, nixpkgs, zosSporeVialFlake, narBridgeFlake }:
    let
      pkgs = nixpkgs.legacyPackages.aarch64-linux;

      # Get the ZOS Spore Vial (the NAR archive)
      zosSporeVial = zosSporeVialFlake.packages.aarch64-linux.default;

      # Restore the ZOS Spore Vial into the lab environment
      restoredSpore = narBridgeFlake.lib.restoreNar {
        name = "restored-zos-spore";
        narFile = zosSporeVial;
      };

      # The "cultivation" process
      cultivatedSpore = pkgs.runCommand "cultivated-zos-spore"
        {
          buildInputs = [ pkgs.bash pkgs.jq ]; # Add any tools needed for cultivation
          inherit restoredSpore;
        } ''
        mkdir -p $out/cultivated-output

        echo "DEBUG: Restored spore path: $(cat "$restoredSpore/restored-path")"
        RESTORED_PATH=$(cat "$restoredSpore/restored-path")

        echo "DEBUG: Contents of restored spore:"
        ls -la "$RESTORED_PATH"

        # Example cultivation: Read the ZOS elements and perform a simple transformation
        echo "Cultivating ZOS spore..."
        jq -c . "$RESTORED_PATH/elements.json" > "$out/cultivated-output/transformed-elements.json"
        echo "Self-description:"
        cat "$RESTORED_PATH/self-description.md" >> "$out/cultivated-output/self-description-copy.md"

        echo "Spore cultivated successfully in $out/cultivated-output"
      '';
    in
    {
      packages.aarch64-linux.default = cultivatedSpore;
    };
}
