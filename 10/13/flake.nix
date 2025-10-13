{
  description = "Nix flake for today's directory (October 13, 2025)";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        # Define packages, devShells, etc. here
        # For now, a simple default package that echoes a message
        packages.default = pkgs.runCommand "today-flake-output" { } ''
          mkdir -p $out/bin
          echo '#!${pkgs.bash}/bin/bash' > $out/bin/hello-today
          echo 'echo "Hello from today\'s flake!"' >> $out/bin/hello-today
          chmod +x $out/bin/hello-today
        '';

        devShells.default = pkgs.mkShell {
          packages = [
            pkgs.nix
          ];
        };
      }
    );
}
