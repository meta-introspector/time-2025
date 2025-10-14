{
  description = "Evaluates allNars from nar-binstore-builder";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    narBinstoreBuilder.url = "../nar-binstore-builder"; # Relative path from this flake to nar-binstore-builder
  };

  outputs = { self, nixpkgs, narBinstoreBuilder, ... }:
    let
      system = "x86_64-linux"; # Assuming x86_64-linux as per the user's example
      pkgs = nixpkgs.legacyPackages.${system};
    in
    {
      # This output will contain the result of narBinstoreBuilder.lib.${system}.allNars
      # We can make it an attribute or a package, depending on what's needed.
      # For raw evaluation, we just need to expose it.
      allNarsOutput = narBinstoreBuilder.lib.${system}.allNars;
    };
}
