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
#   - Prime Exponents: { "2": 4, "3": 2, "5": 1, "7": 0, "11": 0, "13": 0, "17": 0, "19": 0, "23": 0, "29": 0, "31": 0, "41": 0, "47": 0, "59": 0, "71": 0 }
#   - Emoji Representation: ☀️☀️☀️☀️🌑🌑🖐️
# -------------------
{ lib, path, name }:
    let
      # Helper function to parse a .gitmodules file
      parseGitmodules = gitmodulesPath:
        let
          content = builtins.readFile gitmodulesPath;
          # Regex to find submodule sections
          # This regex is basic and might need refinement for robustness
          # It matches one submodule section at a time
          submoduleRegex = ''
            \[submodule "([^"]+)"\]
            \s*path = ([^\n]+)
            \s*url = ([^\n]+)
            (?:\s*branch = ([^\n]+))?
          '';
          # Use lib.strings.match to find all matches
          # lib.strings.match returns a list of lists, where each inner list is a match
          # and its capturing groups.
          matches = lib.strings.match submoduleRegex content;

          # Function to extract info from a single match
          extractSubmoduleInfo = match:
            let
              # The first element of 'match' is the full matched string,
              # subsequent elements are the capturing groups.
              name = lib.elemAt match 1; # First capturing group: submodule name
              subPath = lib.elemAt match 2; # Second capturing group: path
              url = lib.elemAt match 3; # Third capturing group: url
              # Check if the branch capturing group exists
              branch = if (lib.length match) > 4 then lib.elemAt match 4 else null;
            in
            { inherit name subPath url branch; };
        in
        lib.map extractSubmoduleInfo matches;

      # Get .nix files in the current path
      nixFiles = lib.filter (
        file: builtins.match ".*\\.nix" file != null
      ) (builtins.attrNames (builtins.readDir path));

      # Get submodules in the current path
      gitmodulesPath = path + "/.gitmodules";
      submodulesRaw = if builtins.pathExists gitmodulesPath then parseGitmodules gitmodulesPath else [];

      # Recursively process submodules
      submoduleContexts = lib.listToAttrs (
        lib.map (
          sub: { 
            inherit (sub) name;
            value = wrap_context { inherit lib; path = path + "/" + sub.subPath; inherit (sub) name; };
          }
        ) submodulesRaw
      );

    in
    {
      inherit name;
      files = map (file: path + "/" + file) nixFiles;
      inherit submoduleContexts;
    }
