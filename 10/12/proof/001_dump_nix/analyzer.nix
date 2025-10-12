{ pkgs, lib, builtins, rnix-parser, projectRoot, nixFile, extraArgs ? { } }:
let
  system = "aarch64-linux";
  # Merge extraArgs with the function's arguments, giving extraArgs lower precedence
  args = { inherit pkgs lib builtins rnix-parser projectRoot nixFile system; } // extraArgs;

  # Read the content of the Nix file
  fileContent = builtins.readFile (args.projectRoot + "/${args.nixFile}");

  # Use rnix-parser to parse the content into an AST
  # rnix-parser.lib.parse takes a string and returns an AST
  parsed = args.rnix-parser.lib.parse fileContent;

  # Function to extract function arguments from an AST
  # This is a simplified example and might need more sophisticated AST traversal
  extractFunctionArgs = ast:
    if ast.type == "lambda" then
    # Assuming a simple lambda like `{ arg1, arg2 }: ...`
    # The arguments are usually in the 'params' field of the lambda node
    # This needs to be refined based on the actual rnix-parser AST structure
    # For now, let's just return a placeholder
      "Function arguments: (needs AST traversal)"
    else
      "Not a function";

  # Function to extract flake inputs from an AST
  extractFlakeInputs = ast:
    if ast.type == "attrSet" && args.lib.hasAttr "inputs" ast.members then
    # Assuming a flake.nix structure with an 'inputs' attribute set
    # This needs to be refined based on the actual rnix-parser AST structure
      "Flake inputs: (needs AST traversal)"
    else
      "Not a flake";

in
{
  fileName = args.nixFile;
  isFunction = parsed.type == "lambda"; # Simplified check
  isFlake = parsed.type == "attrSet" && args.lib.hasAttr "inputs" parsed.members; # Simplified check
  functionArgs = extractFunctionArgs parsed;
  flakeInputs = extractFlakeInputs parsed;
  # You can also return the full AST for debugging
  # ast = parsed;
}
