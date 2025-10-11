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
#   - Prime Exponents: { "2": 3, "3": 2, "5": 1, "7": 0, "11": 0, "13": 0, "17": 0, "19": 0, "23": 0, "29": 0, "31": 0, "41": 0, "47": 0, "59": 0, "71": 0 }
#   - Emoji Representation: ☀️☀️☀️🌑🌑🖐️
# -------------------
{ lib, pkgs }:

let
  # Path to the .gitmodules file for pick-up-nix context
  pickUpNixGitmodulesPath = ../../context/pick-up-nix/.gitmodules;
  # Path to the .gitmodules file for streamofrandom context
  streamOfRandomGitmodulesPath = ../../context/streamofrandom/.gitmodules;

  # Function to parse a .gitmodules file
  parseGitmodules = gitmodulesPath:
    let
      content = builtins.readFile gitmodulesPath;
      # Regex to find submodule sections
      submoduleSections = lib.strings.match ''^[[submodule "([^"]+)"[[\n\s*path = ([^\n]+)\n\s*url = ([^\n]+)(\n\s*branch = ([^\n]+))?'' content;
      # This regex is very basic and will need refinement for robustness

      # Function to extract info from a single match
      extractSubmoduleInfo = match:
        let
          name = lib.head match.captures;
          path = lib.head (lib.tail match.captures);
          url = lib.head (lib.tail (lib.tail match.captures));
          branch = if (lib.length match.captures) > 4 then lib.head (lib.tail (lib.tail (lib.tail (lib.tail match.captures)))) else null;
        in
        { inherit name path url branch; };
    in
    lib.map extractSubmoduleInfo submoduleSections;

  # Parse .gitmodules files
  pickUpNixSubmodules = if builtins.pathExists pickUpNixGitmodulesPath then parseGitmodules pickUpNixGitmodulesPath else [];
  streamOfRandomSubmodules = if builtins.pathExists streamOfRandomGitmodulesPath then parseGitmodules streamOfRandomGitmodulesPath else [];

  # Combine all submodules
  allContextSubmodules = pickUpNixSubmodules ++ streamOfRandomSubmodules;

  # Create explicit lookups for submodules
  submoduleLookups = lib.listToAttrs (lib.map (sub: {
    inherit (sub) name;
    value = sub;
  }) allContextSubmodules);

in
{
  # Expose submodule lookups
  inherit submoduleLookups;
  # Expose the raw list of submodules
  inherit allContextSubmodules;
}