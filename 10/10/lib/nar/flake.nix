
{
  description = "A flake to export the nix-file-list to a NAR file";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    nix2.url = "github:meta-introspector/time-2025?ref=feature/git-nix-file-list&dir=10/10/nix2";
  };

  outputs = { self, nixpkgs, nix2 }:
    let
      system = "aarch64-linux";
      pkgs = import nixpkgs { inherit system; };
      branch = "d670d37ce328808bfc0a8e8c6c7d49a61c11d843"; # feature/git-nix-file-list
      getNixFileList = (import "${nix2}/get-nix-file-list/flake.nix") { inherit pkgs; };
    in
    {
      packages.${system}.default = pkgs.runCommand "nix-file-list-nar" {} ''
        # Generate the JSON file
        ${pkgs.nix}/bin/nix eval --json --expr '${getNixFileList}' > nix-file-list.json

        # Add the JSON file to the store
        store_path=$(${pkgs.nix}/bin/nix-store --add nix-file-list.json)

        # Dump the store path to a NAR file
        ${pkgs.nix}/bin/nix-store --dump $store_path > $out
      '';
    };
}
