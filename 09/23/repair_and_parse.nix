let
  pkgs = import <nixpkgs> { };
  inherit (pkgs) lib;

  # Read the content of the test file
  testFile = ./ngram_index_test.json;
  fileContent = builtins.readFile testFile;

  # Split the content into lines and filter out any empty lines
  lines = lib.splitString "\n" fileContent;
  nonEmptyLines = lib.filter (line: line != "") lines;

  # Reconstruct the lines, adding a comma before each line that starts
  # a new key-value pair (which we assume is any line starting with a quote).
  # We skip adding a comma for the very first line (index 0).
  repairedLines = lib.imap0
    (i: line:
      if lib.hasPrefix "\"" line && i > 0 then ",\n" + line
      else line
    )
    nonEmptyLines;

  # Join the repaired lines back into a single string
  repairedContent = lib.concatStrings repairedLines;

  # Wrap the content in curly braces to form a valid JSON object
  jsonString = "{\n" + repairedContent + "\n}";

  # Parse the repaired JSON string
  parsedData = builtins.fromJSON jsonString;

in
# As a proof of successful parsing, return the number of keys in the object
lib.length (lib.attrNames parsedData)
