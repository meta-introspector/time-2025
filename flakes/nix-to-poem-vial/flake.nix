{
  description = "Vial for converting Nix code to a poem.";

  outputs = { self, ... } @ args:
    {
      lib.getPrompt = { pkgs, nixFileContent }:
        ''
          Convert the following Nix code into a poem. Focus on the structure, purpose, and any interesting patterns or abstractions.

          Nix Code:
          ```nix
          ${nixFileContent}
          ```
        '';
    };
}
