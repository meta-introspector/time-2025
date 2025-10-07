let
  pkgs = import <nixpkgs> { };
  inherit (pkgs) lib;
  testFile = ./ngram_index_test.json;
  fileContent = builtins.readFile testFile;
  lines = lib.splitString "\n" fileContent;
  nonEmptyLines = lib.filter (line: line != "") lines;
  repairedLines = lib.imap0
    (i: line:
      if lib.hasPrefix "\"" line && i > 0 then ",\n" + line
      else line
    )
    nonEmptyLines;
  repairedContent = lib.concatStrings repairedLines;
  jsonString = "{\n" + repairedContent + "\n}";
in
jsonString
