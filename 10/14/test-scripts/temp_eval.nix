let
  flake = builtins.getFlake (toString ../flake_auditor);
  naerskLib = flake.inputs.naersk.lib.aarch64-linux;
in
builtins.attrNames naerskLib
