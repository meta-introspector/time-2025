let
  nixpkgs = import (builtins.getFlake "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify") { system = "aarch64-linux"; };
in
nixpkgs.pkgs.nix.version
