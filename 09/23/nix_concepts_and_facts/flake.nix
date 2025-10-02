{
  description = "Nix derivations for numerical exploration concepts and AI context.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
    crqBinstore = {
      url = "github:meta-introspector/crq-binstore"; # Input for the CRQ binstore
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, crqBinstore } @ inputs:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
        nixLib = pkgs.lib; # Make lib available as nixLib

        zos = import ./lib/zos.nix { pkgs = pkgs; crqBinstore = crqBinstore; nixLib = nixLib; };
        concepts = import ./lib/concepts.nix { pkgs = pkgs; flakeSelf = self; nixLib = nixLib; };
        aiContext = import ./lib/ai-context.nix { pkgs = pkgs; concepts = concepts; zos = zos; nixLib = nixLib; };

      in
      {
        packages.default = aiContext; # Make aiContext the default package
        defaultPackage = aiContext; # Explicitly define default package
        number-23 = concepts.mkNumber 23;
        inherit (concepts) is-prime-23 fact-23-oracle;
      }
    );
}
