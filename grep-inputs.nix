{ pkgs ? import <nixpkgs> {}, src ? builtins.toString ./. } :

let
  # Define the regexes to search for
  regexes = [
    "inputs\\."
  ];

  # Convert the list of regexes into a format suitable for grep -E
  grepPatterns = pkgs.lib.concatStringsSep "|" regexes;

  # Find all .nix files in the current directory and subdirectories
  # and grep them for the defined regexes.
  grepResult = pkgs.runCommand "grep-inputs-results" {
    buildInputs = [ pkgs.gnugrep pkgs.findutils ];
  }
  ''
    set -euxo pipefail # Enable debugging and exit on error
    
    echo "DEBUG: Current directory: $(pwd)"
    echo "DEBUG: Value of $out: $out"
    mkdir -p $out # Create the output directory
    echo "DEBUG: Contents of $out after mkdir:"
    ls -la $out
    
    echo "Searching for inputs. in Nix files in ${src}..."
    find "${src}" -name "*.nix" -print0 | xargs -0 grep -E "${grepPatterns}" > "$out/grep-results.txt" || true # Allow grep to run even if no matches are found
    
    echo "DEBUG: Contents of $out after grep:"
    ls -la $out
    
    echo "Grep results captured in $out/grep-results.txt"
  '';

in
  grepResult
