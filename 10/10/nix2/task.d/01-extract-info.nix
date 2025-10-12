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
{ lib, pkgs, firstReflection, allFlakeNixFiles, allGitmodulesFiles }:

let
  extractedInfo = {
    flakeCommands = lib.flatten (lib.map (flakePath: (firstReflection.identityPrincipleSpec.rawCommandExtraction.extractFlakeCommands flakePath).commands) allFlakeNixFiles);
    flakeUrls = lib.flatten (lib.map (flakePath: (firstReflection.identityPrincipleSpec.rawCommandExtraction.extractFlakeCommands flakePath).urls) allFlakeNixFiles);
    flakeSystems = lib.flatten (lib.map (flakePath: (firstReflection.identityPrincipleSpec.rawCommandExtraction.extractFlakeCommands flakePath).systems) allFlakeNixFiles);
    submoduleUrls = lib.flatten (lib.map (gitmodulesPath: firstReflection.identityPrincipleSpec.rawCommandExtraction.extractSubmoduleUrls gitmodulesPath) allGitmodulesFiles);
    submoduleBranches = lib.flatten (lib.map (gitmodulesPath: firstReflection.identityPrincipleSpec.rawCommandExtraction.extractSubmoduleBranches gitmodulesPath) allGitmodulesFiles);
  };

in
extractedInfo
