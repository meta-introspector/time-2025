{
  description = "Dummy MCTS Nix package for testing.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
  };

  outputs = { self, nixpkgs }:
    let
      pkgs = nixpkgs.legacyPackages.aarch64-linux;
    in
    {
      packages.aarch64-linux.default = pkgs.runCommand "dummy-mcts-engine" {
        buildInputs = [ pkgs.bash ];
      } ''
        mkdir -p $out/bin
        echo "#!${pkgs.bash}/bin/bash" > $out/bin/mcts-solver
        echo 'echo "Dummy MCTS solver output for schedule: $1, config: $2" >&2' >> $out/bin/mcts-solver
        echo 'echo "{\"best_action\": \"task_A\", \"confidence\": 0.8}"' >> $out/bin/mcts-solver
        chmod +x $out/bin/mcts-solver
      '';
    };
}
