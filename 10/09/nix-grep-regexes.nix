{ pkgs ? import <nixpkgs> { system = "aarch64-linux"; } }:

let
  # Define the regexes to search for
  narRegexes = [
    "nix-nar"
    "nar pack"
    "nar unpack"
    "nix-store --import"
    "nix-store --export"
    "nix archive"
    "nix store dump-path"
  ];

  # Convert the list of regexes into a format suitable for grep -E
  grepPatterns = pkgs.lib.concatStringsSep "|" narRegexes;

  # Find all .nix files in the current directory and subdirectories
  # and grep them for the defined regexes.
  grepResult = pkgs.runCommand "nix-nar-grep-results" {
    buildInputs = [ pkgs.gnugrep pkgs.findutils ];
    # The source of the files to grep. Assuming current directory for now.
    # In a real flake, this would be an input.
    src = ./.;
  } ''
    echo "Searching for NAR-related patterns in Nix files..."
    find "$src" -name "*.nix" -exec grep -E "${grepPatterns}" {} + > "$out/grep-results.txt"
    echo "Grep results captured in $out/grep-results.txt"
  '';

in
  grepResult