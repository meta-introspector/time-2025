let
  flake = builtins.getFlake (toString ./.);
  parserLib = flake.lib;
  testFilename = "CRQ_001_Log_Analysis_Pure_Derivation.md";
  result = parserLib.parseCrqFilename testFilename;
in
builtins.toJSON result
