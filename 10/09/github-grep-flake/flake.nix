{
  description = "A flake to grep a GitHub repository for specific patterns.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    # The GitHub repository to grep
    targetRepo = {
      url = "github:meta-introspector/time-2025?ref=feature/lattice-30030-homedir";
      flake = false; # We want the source, not a flake output
    };
  };

  outputs = { self, nixpkgs, targetRepo }:
    let
      pkgs = nixpkgs.legacyPackages.aarch64-linux;
      # Import the local nix-grep-regexes.nix directly as a function
      nixGrepRegexesFn = import ../nix-grep-regexes.nix;
      # Call the nix-grep-regexes.nix function with the fetched targetRepo as src
      grepResults = nixGrepRegexesFn {
        inherit pkgs;
        src = targetRepo;
      };
    in
    {
      packages.aarch64-linux.default = grepResults;
    };
}