let
  nixpkgs = import (builtins.fetchTarball {
    url = "https://github.com/meta-introspector/nixpkgs/archive/feature/CRQ-016-nixify.tar.gz";
  }) { system = "aarch64-linux"; };

  lib = nixpkgs.lib;

  # Static instance of data mimicking indexedFiles
  staticData = [
    { path = "foo/test1.nix"; hash = "hash1"; }
    { path = "bar/test2.nix"; hash = "hash2"; }
  ];

  flattenedData = lib.flatten staticData;

in
builtins.toJSON flattenedData
