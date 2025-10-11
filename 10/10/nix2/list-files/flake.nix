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
#   - Prime Exponents: { "2": 2, "3": 1, "5": 1, "7": 0, "11": 0, "13": 0, "17": 0, "19": 0, "23": 0, "29": 0, "31": 0, "41": 0, "47": 0, "59": 0, "71": 0 }
#   - Emoji Representation: ☀️☀️🌑🖐️
# -------------------
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
      inherit (pkgs) lib;
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