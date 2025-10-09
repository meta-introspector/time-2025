{
  description = "A flake that consumes raw hackathon pages and converts them to JSON.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs/26833ad1dad83826ef7cc52e0009ca9b7097c79f";
    hackathon-status-raw.flake = false; # This will be overridden by the bridge
  };

  outputs = { self, nixpkgs, hackathon-status-raw }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in
    {
      packages.x86_64-linux.default = pkgs.stdenv.mkDerivation {
        name = "hackathon-status-json";
        src = hackathon-status-raw;
        buildInputs = [ pkgs.pandoc ];

        buildPhase = ''
          mkdir -p $out
          # Find all html files and convert them to json
          for file in $(find $src -name "*.html"); do
            pandoc -s -t json -o $out/$(basename $file .html).json $file
          done
        '';

        installPhase = ''
          # The files are already in $out
          :
        '';
      };
    };
}
