{
  description = "A 'Do What I Mean' flake that generates a project scaffold based on a prompt.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    llmGeneratorFlake.url = "github:meta-introspector/time-2025?ref=7c2ef1198c1ae2ef45c09dc18d3d4dc2d580e9bb&dir=10/14";
    metaOrchestratorFlake.url = "github:meta-introspector/time-2025?ref=7c2ef1198c1ae2ef45c09dc18d3d4dc2d580e9bb&dir=10/15/meta-orchestrator";

  };

  outputs = { self, nixpkgs, flake-utils, llmGeneratorFlake, metaOrchestratorFlake }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;
        builtins = builtins; # Expose builtins
      in
      {
        packages.default = { promptString }:
          (import ./default.nix {
            inherit pkgs lib builtins llmGeneratorFlake metaOrchestratorFlake;
          }) promptString;

        packages.typeReport = pkgs.writeText "dwim-type-report.json" (builtins.toJSON {
          outputs = {
            lib = {
              type = "attrset";
              attrs = {
                dwimFunction = {
                  type = "function";
                  args = {
                    promptString = "string";
                  };
                };
              };
            };
          };
        });

        # Expose the function directly for more advanced usage
        lib.dwimFunction = { promptString }:
          (import ./default.nix {
            inherit pkgs lib builtins llmGeneratorFlake metaOrchestratorFlake;
          }) promptString;
      }
    );
}
