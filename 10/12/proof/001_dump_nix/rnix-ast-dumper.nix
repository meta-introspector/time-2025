# 10/12/proof/001_dump_nix/rnix-ast-dumper.nix
{ rnix-parser
, # The rnix-parser flake input, providing parsing capabilities
  filePath
, # The absolute path to the .nix file to be parsed
  builtins     # The Nix builtins, specifically for builtins.readFile
}:
let
  fileContent = builtins.readFile filePath;
  parsedAst = rnix-parser.lib.parse fileContent;
in
{
  inherit filePath;
  ast = parsedAst;
}
