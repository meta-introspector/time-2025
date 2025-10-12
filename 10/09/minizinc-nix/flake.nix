{
  description = "Dummy MiniZinc Nix package for testing.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
  };

  outputs = { self, nixpkgs }:
    let
      pkgs = nixpkgs.legacyPackages.aarch64-linux;
    in
    {
      packages.aarch64-linux.default = pkgs.runCommand "dummy-minizinc"
        {
          buildInputs = [ pkgs.bash ];
        } ''
        mkdir -p $out/bin
        echo '#!${pkgs.bash}/bin/bash' > $out/bin/minizinc
        echo 'echo "Dummy MiniZinc output for model: $1, data: $2" >&2' >> $out/bin/minizinc
        echo 'echo "makespan = 10;"' >> $out/bin/minizinc
        chmod +x $out/bin/minizinc
      '';
    };
}
