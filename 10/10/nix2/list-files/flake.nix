{
  description = "A simple flake to provide nixpkgs from meta-introspector";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    # Add get-nix-file-list.nix as an input
    getNixFileList = {
      url = "path:../../get-nix-file-list.nix"; # Relative path to the file
      flake = false; # It's a plain Nix expression, not a flake
    };
  };

  outputs = { self, nixpkgs, getNixFileList }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux; # Assuming x86_64-linux for now
      lib = pkgs.lib;
      # Evaluate get-nix-file-list.nix to get the list of files
      nixFilesList = getNixFileList { inherit pkgs lib; };
    in
    {
      # Expose nixpkgs as a package
      packages.x86_64-linux.default = nixpkgs;
      # Also expose it directly for easier access to its path
      lib.nixpkgsPath = nixpkgs;

      # Expose the list of Nix files as a knowledge artifact
      # This will create a derivation that contains a file with the JSON list of files
      packages.x86_64-linux.nixFilesArtifact = pkgs.writeText "nix-files-list.json" (builtins.toJSON nixFilesList);
    };
}