{ lib, ... }:

let
  # Function to extract direct inputs of a flake
  extractDirectInputs = flake:
    let
      inputs = flake.inputs or { };
    in
    lib.mapAttrs'
      (name: value: {
        inherit name;
        value = {
          url = value.url or null;
          rev = value.rev or null;
          # Add more metadata extraction here as needed
        };
      })
      inputs;

  # Recursive function to traverse flake dependencies
  # This is a placeholder and will be expanded later
  traverseFlakeDependencies = flake:
    let
      directInputs = extractDirectInputs flake;
    in
    {
      flake = {
        url = flake.url or null;
        rev = flake.rev or null;
      };
      dependencies = directInputs;
    };

in
{
  # Expose the main function for NotebookLM export
  # This will take a flake and return a structured description
  notebooklmExport = traverseFlakeDependencies;
}
