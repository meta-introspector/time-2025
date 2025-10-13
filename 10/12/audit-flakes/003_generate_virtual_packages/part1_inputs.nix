{
  description = "A flake to generate virtual packages and emoji strings from extracted flake data.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    # Input from the previous step: a derivation containing a JSON file with extracted data
    extractedData = {
      url = "path:../002_extract_data";
    };
  };
