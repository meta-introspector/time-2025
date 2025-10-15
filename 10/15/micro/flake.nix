{
  description = "A micro flake to cat a specific flake.nix from the Nix store.";

  outputs = { self }:
    let
      system = "aarch64-linux"; # Assuming aarch64-linux as per previous interactions
      pkgs = import <nixpkgs> { inherit system; };
      targetFlakeNix = "/nix/store/82nxsgmkw3f4ady2d7jkmp84q536v7bb-source/flake.nix";
    in
    {
      packages.${system}.default = pkgs.runCommand "cat-flake-nix"
        {
          buildInputs = [ pkgs.coreutils ]; # For 'cat'
        } ''
        mkdir -p $out
        cat ${targetFlakeNix} > $out/flake.nix.content
      '';

      apps.${system}.default = {
        type = "app";
        program = "${self.packages.${system}.default}/flake.nix.content";
      };
    };
}
