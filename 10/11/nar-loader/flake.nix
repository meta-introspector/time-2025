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
#   - Prime Exponents: { "2": 3, "3": 1, "5": 2, "7": 1, "11": 0, "13": 1, "17": 0, "19": 0, "23": 0, "29": 0, "31": 0, "41": 0, "47": 0, "59": 0, "71": 0 }
#   - Emoji Representation: ☀️☀️☀️🌑🖐️🖐️🚶‍♀️🦋
# -------------------
{
  description = "Nix flake for loading and searching NAR files within the structured binstore.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    # The nar-locator flake is needed to understand the structure of the binstore
    narLocatorFlake = {
      url = "path:../nar-locator"; # Relative path to the nar-locator flake
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, narLocatorFlake }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = nixpkgs.lib;

        # Base path for the structured binstore (where NARs are stored by nar-locator)
        binstoreBasePath = "${narLocatorFlake}/nar-outputs/09/22/crq-binstore";

        # Function to load a specific NAR by its canonical path
        # canonicalNarPath: The full path to the NAR file within the binstore (e.g., nix-files/my_flake.nix.nar)
        loadNar = { canonicalNarPath }:
          let
            fullPath = "${binstoreBasePath}/${canonicalNarPath}";
          in
          pkgs.runCommand "loaded-nar-${lib.strings.removeSuffix ".nar" (lib.strings.baseNameOf canonicalNarPath)}" {
            nativeBuildInputs = [ pkgs.nix pkgs.nix-nar-unpack ];
            narFile = fullPath;
          } ''
            echo "Loading NAR from ${narFile}"
            mkdir -p $out
            nix-nar-unpack --file ${narFile} --to $out
            echo "NAR unpacked to $out"
          '';

        # Function to search for NARs based on a query
        # query: A string to search for in the originalFilePath of the NARs
        # searchContent: Boolean, if true, unpacks matching NARs and searches their content
        searchNars = { query, searchContent ? false }:
          let
            # Dynamically list all NAR files in the binstore
            allNarFiles = lib.attrValues (
              lib.mapAttrsRecursive (name: value: if lib.isDerivation value && lib.strings.hasSuffix ".nar" value.name then value else null)
              (lib.readDir binstoreBasePath)
            );

            # Filter NARs that contain the query string in their path
            matchingNarPaths = lib.filter (narFile: lib.strings.hasInfix query narFile.name) allNarFiles;

            # If searchContent is true, unpack and grep the content
            contentSearchResults = if searchContent then
              lib.map (
                narFile: pkgs.runCommand "nar-content-search-${narFile.name}" {
                  nativeBuildInputs = [ pkgs.nix pkgs.nix-nar-unpack pkgs.gnugrep pkgs.findutils ];
                  narToUnpack = narFile;
                  searchQuery = query;
                } ''
                  echo "Searching content of ${narToUnpack.name} for \"${searchQuery}\"..."
                  local temp_unpack_dir=$(mktemp -d)
                  nix-nar-unpack --file ${narToUnpack} --to $temp_unpack_dir
                  
                  # Grep for the query in the unpacked content
                  local grep_output=$(find $temp_unpack_dir -type f -print0 | xargs -0 grep -i -l "${searchQuery}" || true)

                  if [[ -n "$grep_output" ]]; then
                    echo "Match found in content of ${narToUnpack.name}:"
                    echo "$grep_output" | sed "s|^${temp_unpack_dir}/|  |" # Prettify output
                    echo "${narToUnpack}" > $out # Output the path to the NAR if content matches
                  else
                    echo "No match found in content of ${narToUnpack.name}"
                    # If no match, output an empty string or a specific marker
                    # For now, we'll just not create an output if no match
                    exit 0
                  fi
                ''
              ) matchingNarPaths
            else [];

            # Combine path matches and content matches (if any)
            # For simplicity, we'll just return the paths of NARs that matched either way
            # In a real RAG system, you'd return more structured results.
            allResults = lib.unique (matchingNarPaths ++ contentSearchResults);
          in
          allResults;

      in
      {
        lib = { inherit loadNar searchNars; };
        # Example of a default package for easy use
        packages.default = self.lib.loadNar {
          canonicalNarPath = "nix-files/09_27_7-concepts_ai-workflow_flake.nix.nar"; # Placeholder
        };
      }
    );
}
