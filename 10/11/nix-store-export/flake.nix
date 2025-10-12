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
#   - Prime Exponents: { "2": 2, "3": 1, "5": 0, "7": 1, "11": 0, "13": 0, "17": 0, "19": 0, "23": 0, "29": 0, "31": 0, "41": 0, "47": 0, "59": 0, "71": 0 }
#   - Emoji Representation: ☀️☀️🌑🚶‍♀️
# -------------------
{
  description = "Nix flake for wrapping nix-store --export calls.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        inherit (nixpkgs) lib;

        # Function to create a derivation that exports a store path to a tarball
        # storePath: The Nix store path to export
        # exportFileName: The desired filename for the resulting tarball (e.g., my-export.tar.gz)
        exportStorePath = { storePath, exportFileName }:
          pkgs.stdenv.mkDerivation {
            pname = "nix-store-export-${lib.strings.removeSuffix ".tar.gz" exportFileName}";
            version = "0.1.0";

            nativeBuildInputs = [ pkgs.nix ];

            # The actual script that performs the export
            buildPhase = ''
              echo "Exporting store path ${storePath} to ${exportFileName}"
              ${pkgs.nix}/bin/nix-store --export ${storePath} > ${exportFileName}
            '';

            # Install the generated tarball as the primary output
            installPhase = ''
              mkdir -p $out
              mv ${exportFileName} $out/${exportFileName}
            '';

            # Ensure the storePath is a dependency
            passthru.storePath = storePath;
          };

      in
      {
        lib = { inherit exportStorePath; };
        # Example of a default package for easy use
        packages.default = self.lib.exportStorePath {
          storePath = "/nix/store/some-default-path"; # Placeholder, should be overridden
          exportFileName = "default-export.tar.gz";
        };
      });
}
