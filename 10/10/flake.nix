
{
  description = "A flake to export the nix-file-list to a NAR file";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
  };

  outputs = { self, nixpkgs }:
    let
      system = "aarch64-linux";
      pkgs = import nixpkgs { inherit system; };
      nix2-src = pkgs.lib.sources.cleanSource ./nix2;
      get-nix-file-list = nix2-src + "/get-nix-file-list.nix";
    in
    {
      packages.${system}.default = pkgs.runCommand "nix-file-list-nar" {} ''
        # Generate the JSON file
        ${pkgs.nix}/bin/nix eval --raw -f ${get-nix-file-list} > nix-file-list.json

        # Add the JSON file to the store
        store_path=$(${pkgs.nix}/bin/nix-store --add nix-file-list.json)

        # Dump the store path to a NAR file
        ${pkgs.nix}/bin/nix-store --dump $store_path > $out
      '';
    };
}
