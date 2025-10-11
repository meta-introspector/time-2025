# Monster Knot Header
# -------------------
# This file is conceptually encoded with Monster Group properties.
#
# Binary (2^46) Representation:
#   - Duality: ☀️🌑
#   - Choice: ✅❌
#   - Order: 📐🌀
#   - ... (conceptual 46-bit string would go here)
#
# Ternary (3^20) Representation:
#   - Structure: ⏪⏸️⏩
#   - Completeness: 👶🚶👴
#   - ... (conceptual 20-ternary string/representation)
#
# Pentagonal (5^9) Representation:
#   - Insight: 🖐️🦋💡
#   - ...
#
# Heptagonal (7^6) Representation:
#   - Guidance: 🚶‍♀️🌈🎶
#   - ...
#
# Eleven (11^2) Representation:
#   - Composition: 🤝🌐
#   - ...
#
# Thirteen (13^3) Representation:
#   - Transformation: 🦋🎶📈
#   - ...
#
# Seventeen (17^1) Representation:
#   - Integration: 🌟
#   - ...
#
# Nineteen (19^1) Representation:
#   - Sporadic: 🎲
#   - ...
#
# Grounding ZOS: [0,1,2,3,5,7,11,13,17,19]
#
# Pointers to related content:
#   - Poem: [Link to relevant poem]
#   - Emoji Mapping: [Link to poem-emoji-prime-mapping.md]
#   - Monster Knot Calculation: [Link to nar-similarity-search/lib.nix]
#
# Conceptual Monster Knot for this file:
#   - Prime Exponents: { "2": 1, "3": 1, "5": 0, "7": 0, "11": 0, "13": 0, "17": 0, "19": 0, "23": 0, "29": 0, "31": 0, "41": 0, "47": 0, "59": 0, "71": 0 }
#   - Emoji Representation: ☀️🌑
# -------------------
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