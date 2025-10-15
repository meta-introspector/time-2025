{
  description = "A 'Do What I Mean' flake that generates a project scaffold based on a prompt.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    llmGeneratorFlake.url = "github:meta-introspector/time-2025?ref=feature/aimyc-003-cultivation&dir=10/14";
    metaOrchestratorFlake.url = "github:meta-introspector/time-2025?ref=feature/aimyc-003-cultivation&dir=10/15/meta-orchestrator";
    self = { url = "path:./."; }; # Reference to the current flake
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

        # Expose the function directly for more advanced usage
        lib.dwimFunction = { promptString }:
          (import ./default.nix {
            inherit pkgs lib builtins llmGeneratorFlake metaOrchestratorFlake;
          }) promptString;
      }
    );
}
