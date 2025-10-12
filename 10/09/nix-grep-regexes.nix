{ pkgs, src }:

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
  grepResult = pkgs.runCommand "nix-nar-grep-results"
    {
      buildInputs = [ pkgs.gnugrep pkgs.findutils ];
      inherit src; # Use the provided src
    } ''
    set -euxo pipefail # Enable debugging and exit on error
    
    echo "DEBUG: Current directory: $(pwd)"
    echo "DEBUG: Value of $out: $out"
    mkdir -p $out # Create the output directory
    echo "DEBUG: Contents of $out after mkdir:"
    ls -la $out
    
    echo "Searching for NAR-related patterns in Nix files in $src..."
    find "$src" -name "*.nix" -print0 | xargs -0 grep -E "${grepPatterns}" > "$out/grep-results.txt" || true # Allow grep to exit with 1 if no matches
    
    echo "DEBUG: Contents of $out after grep:"
    ls -la $out
    
    echo "Grep results captured in $out/grep-results.txt"
  '';

in
grepResult
