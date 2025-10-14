{
  description = "A flake to cultivate the Monster Group prime lattice.";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      lattice = import ./monster-group-prime-lattice.nix { };
    in
    {
      packages.x86_64-linux.monster-lattice = pkgs.runCommand "monster-lattice.json" { } ''
        ${pkgs.jq}/bin/jq -n '${builtins.toJSON lattice}' > $out
      '';

      apps.x86_64-linux.default = {
        type = "app";
        program = "${self.packages.x86_64-linux.monster-lattice}/bin/cat";
      };
    };
}
