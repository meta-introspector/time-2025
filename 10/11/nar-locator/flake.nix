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
#   - Prime Exponents: { "2": 4, "3": 1, "5": 1, "7": 1, "11": 0, "13": 0, "17": 0, "19": 0, "23": 0, "29": 0, "31": 0, "41": 0, "47": 0, "59": 0, "71": 0 }
#   - Emoji Representation: ☀️☀️☀️☀️🌑🖐️🚶‍♀️
# -------------------
{
  description = "Nix flake for locating and archiving store paths into a structured binstore.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    nixStoreDumpFlake = {
      url = "path:../nix-store-dump"; # Relative path to the nix-store-dump flake
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixStoreExportFlake = {
      url = "path:../nix-store-export"; # Relative path to the nix-store-export flake
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, nixStoreDumpFlake, nixStoreExportFlake }: 
    flake-utils.lib.eachDefaultSystem (system: 
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = nixpkgs.lib;

        # Function to sanitize a path for use as a filename or directory name
        sanitizePath = path: lib.strings.replaceStrings ["/" "." "-"] ["_" "_" "_"] path;

        # Function to determine the subdirectory based on file extension
        # This is a simplified version of the "71 subdirectories" concept.
        # In a more advanced implementation, this would use the 8D multivector
        # to determine a category based on the 71 aspects of the Monster Group.
        # For example, a file's 8D multivector could map to one of 71 top-level categories,
        # and then further subcategorized based on other Monster Group factors.
        # One such aspect could be 'markdown files containing the number 71'.
        getCategoryDir = originalFilePath:
          let
            extension = lib.strings.removePrefix "." (lib.strings.fileExt originalFilePath);
          in
          if extension == "" then "no-extension"
          else if lib.elem extension [ "nix" ] then "nix-files"
          else if lib.elem extension [ "sh" ] then "shell-scripts"
          else if lib.strings.hasSuffix "Makefile" originalFilePath then "makefiles" # Handle Makefiles without extension
          else "other"; # Default category

        # Function to locate and archive a store path into the structured binstore
        # storePath: The Nix store path to archive
        # originalFilePath: The original path of the file/directory being archived (for categorization)
        # archiveType: "nar" or "export" (for tarball)
        locateAndArchiveStorePath = { storePath, originalFilePath, archiveType ? "nar" }:
          let
            categoryDir = getCategoryDir originalFilePath;
            baseFileName = sanitizePath originalFilePath;
            
            # Determine the final archive filename and the derivation to call
            archiveInfo = 
              if archiveType == "nar" then {
                fileName = "${baseFileName}.nar";
                derivation = nixStoreDumpFlake.lib.dumpStorePath { inherit storePath; narFileName = "${baseFileName}.nar"; };
              } else if archiveType == "export" then {
                fileName = "${baseFileName}.tar.gz";
                derivation = nixStoreExportFlake.lib.exportStorePath { inherit storePath; exportFileName = "${baseFileName}.tar.gz"; };
              } else {
                # Fallback or error for unknown archiveType
                fileName = "${baseFileName}.unknown";
                derivation = throw "Unknown archiveType: ${archiveType}";
              };

            finalOutputPath = "09/22/crq-binstore/${categoryDir}/${archiveInfo.fileName}";
          in
          pkgs.runCommand "located-archive-${baseFileName}" {
            nativeBuildInputs = [ pkgs.nix ];
            archiveDerivation = archiveInfo.derivation;
          } ''
            mkdir -p $(dirname $out/${finalOutputPath})
            cp ${archiveDerivation} $out/${finalOutputPath}
          '';

      in
      {
        lib = { inherit locateAndArchiveStorePath; };
        # Example of a default package for easy use (defaults to NAR)
        packages.default = self.lib.locateAndArchiveStorePath {
          storePath = "/nix/store/some-default-path"; # Placeholder, should be overridden
          originalFilePath = "some/default/file.nix";
          archiveType = "nar";
        };
      }
    );
}