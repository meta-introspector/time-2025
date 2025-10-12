{
  description = "A flake to grep a GitHub repository for specific patterns.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    # The GitHub repository to grep
    targetRepo = {
      url = "github:meta-introspector/time-2025?ref=feature/lattice-30030-homedir";
      flake = false; # We want the source, not a flake output
    };
    nixGrepRegexes = {
      url = "github:meta-introspector/time-2025?ref=feature/lattice-30030-homedir&dir=10/09/nix-grep-regexes.nix";
      flake = false; # It's a plain Nix expression, not a flake
    };
  };

  outputs = { self, nixpkgs, targetRepo, nixGrepRegexes }:
    let
      pkgs = nixpkgs.legacyPackages.aarch64-linux;
      # Call the nix-grep-regexes.nix function with the fetched targetRepo as src
      grepResults = nixGrepRegexes {
        inherit pkgs;
        src = targetRepo;
      };
    in
    {
      packages.aarch64-linux.default = grepResults;
    };
}
