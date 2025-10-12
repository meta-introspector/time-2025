{
  description = "A flake that fetches raw pages from colosseum.com";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs/26833ad1dad83826ef7cc52e0009ca9b7097c79f";
  };

  outputs = { self, nixpkgs }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in
    {
      packages.x86_64-linux.default = pkgs.stdenv.mkDerivation {
        name = "colosseum-raw-pages";
        buildInputs = [ pkgs.wget ];
        src = pkgs.lib.cleanSource ./.;

        buildPhase = ''
          wget --no-check-certificate --user-agent="solfunmeme.com advanced zk agent" --execute="robots=off" --recursive --no-parent --page-requisites --adjust-extension --convert-links --restrict-file-names=windows --no-clobber \
            https://colosseum.com/ \
            https://colosseum.com/hackathon \
            https://arena.colosseum.org/profiles/solfunmeme \
            https://arena.colosseum.org/projects/explore/minimal-solana-validator-running-on-nix-implementing-zos-solfunmeme-meta-meme-on-solana
        '';

        installPhase = ''
          mkdir -p $out
          mv colosseum.com $out/
          mv arena.colosseum.org $out/
        '';
      };
    };
}
