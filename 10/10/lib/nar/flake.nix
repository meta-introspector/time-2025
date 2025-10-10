
{
  description = "A flake to export the nix-file-list to a NAR file";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    get-nix-file-list-input.url = "github:meta-introspector/time-2025?ref=feature/lattice-30030-homedir&dir=10/10/nix2/get-nix-file-list.nix";
  };

  outputs = { self, nixpkgs, get-nix-file-list-input }:
    let
      system = "aarch64-linux";
      pkgs = import nixpkgs { inherit system; };
      get-nix-file-list = get-nix-file-list-input;
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
