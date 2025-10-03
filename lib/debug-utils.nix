{ lib }:

{
  # Function to convert a Nix value to a JSON string
  toJson = value: lib.toJSON value;

  # Function to print a Nix value as pretty-printed JSON
  # This can be used in a shell or build phase to inspect Nix values
  printJson = value: lib.runCommand "print-json" { }
    "echo '${lib.toJSON value}' | ${lib.jq}/bin/jq . > $out";
}
