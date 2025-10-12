{ pkgs, lib, system, narSimilaritySearch, self }:

pkgs.stdenv.mkDerivation {
  pname = "test-calculate-monster-knot-simple";
  version = "0.1";

  nativeBuildInputs = [ pkgs.bash pkgs.jq ];

  # Create a simple flake for testing
  preBuild = ''
    mkdir -p simple-flake
    echo '{ description = "Simple flake"; outputs = { self, nixpkgs }: { packages.default = nixpkgs.legacyPackages.${system}.hello; }; }' > simple-flake/flake.nix
  '';

  # Evaluate the Nix expression and pass the result to the shell script
  buildPhase = ''
    export MONSTER_KNOT_OUTPUT=$(${narSimilaritySearch.lib.${system}.calculateMonsterKnot (pkgs.path + "/simple-flake")})
    ${pkgs.bash}/bin/bash ${./../scripts/test-calculate-monster-knot-simple.sh} "$MONSTER_KNOT_OUTPUT"
  '';

  installPhase = ''
    mkdir -p $out
    echo "Test passed" > $out/result
  '';
}
