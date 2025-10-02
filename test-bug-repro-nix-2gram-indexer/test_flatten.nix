let
  common = import ../lib/common-imports.nix {};
  lib = common.lib;
  builtins = common.builtins;

  # Static instance of data mimicking indexedFiles
  staticData = [
    { path = "foo/test1.nix"; hash = "hash1"; }
    { path = "bar/test2.nix"; hash = "hash2"; }
  ];

  flattenedData = lib.flatten staticData;

in
builtins.toJSON flattenedData
