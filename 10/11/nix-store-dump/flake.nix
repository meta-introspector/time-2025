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
#   - Prime Exponents: { "2": 3, "3": 1, "5": 0, "7": 1, "11": 0, "13": 0, "17": 0, "19": 0, "23": 0, "29": 0, "31": 0, "41": 0, "47": 0, "59": 0, "71": 0 }
#   - Emoji Representation: ☀️☀️☀️🌑🚶‍♀️
# -------------------
{ description = "Nix flake for performing nix-store --dump operation.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
  };

  outputs = { self, nixpkgs, flake-utils }: 
    flake-utils.lib.eachDefaultSystem (system: 
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = nixpkgs.lib;

        # Function to create a derivation that dumps a store path to a NAR file
        # storePath: The Nix store path to dump (e.g., /nix/store/...) 
        # narFileName: The desired name for the output NAR file (e.g., my-output.nar)
        dumpStorePath = { storePath, narFileName }:
          pkgs.stdenv.mkDerivation {
            pname = "nix-store-dump-${lib.strings.removeSuffix ".nar" narFileName}";
            version = "0.1.0";

            nativeBuildInputs = [ pkgs.nix ];

            # The actual script that performs the dump
            buildPhase = ''
              echo "Dumping store path ${storePath} to ${narFileName}"
              ${pkgs.nix}/bin/nix-store --dump ${storePath} > ${narFileName}
            '';

            # Install the generated NAR file as the primary output
            installPhase = ''
              mkdir -p $out
              mv ${narFileName} $out/${narFileName}
            '';

            # Ensure the storePath is a dependency
            passthru.storePath = storePath;
          };

      in {
        lib = { inherit dumpStorePath; };
        # Example of a default package for easy use
        packages.default = self.lib.dumpStorePath {
          storePath = "/nix/store/some-default-path"; # Placeholder, should be overridden
          narFileName = "default-dump.nar";
        };
      });
}