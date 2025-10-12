{ pkgs }:

pkgs.runCommand "qa-llm-nix-output"
{
  nativeBuildInputs = [ pkgs.nix ]; # Ensure nix is available for nix-instantiate
  # Set NIX_PATH for the build environment to ensure nix-instantiate can find nixpkgs
  NIX_PATH = "nixpkgs=${pkgs.path}";
} ''
  # Execute nix-instantiate directly on the qa.nix file
  nix-instantiate --eval --strict ${./lib-llm-nix/qa.nix} > $out
''
