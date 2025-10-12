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
#   - Prime Exponents: { "2": 1, "3": 2, "5": 0, "7": 1, "11": 0, "13": 0, "17": 0, "19": 0, "23": 0, "29": 0, "31": 0, "41": 0, "47": 0, "59": 0, "71": 0 }
#   - Emoji Representation: ☀️🌑🌑🚶‍♀️
# -------------------
{ pkgs ? import <nixpkgs> { }, narLocatorFlake }:

let
  nix2-src = pkgs.lib.sources.cleanSource ./nix2;
  get-nix-file-list = nix2-src + "/get-nix-file-list.nix";
in
narLocatorFlake.lib.locateAndArchiveStorePath {
  storePath = pkgs.runCommand "nix-file-list-store-path" { } ''
    # Generate the JSON file
    ${pkgs.nix}/bin/nix eval --raw -f ${get-nix-file-list} > nix-file-list.json

    # Add the JSON file to the store
    store_path=$(${pkgs.nix}/bin/nix-store --add nix-file-list.json)

    # The output of this runCommand is the store_path itself
    echo "$store_path" > $out
  '';
  originalFilePath = "nix-file-list.json";
  archiveType = "nar";
}
