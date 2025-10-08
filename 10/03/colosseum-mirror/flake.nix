
{
  description = "Nix derivation to mirror the Colosseum website using httrack.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        colosseumUrl = "https://colosseum.com";
        outputDir = "colosseum-mirror";
      in
      {
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "colosseum-website-mirror";
          version = "2025-10-03"; # Using today's date as version

          nativeBuildInputs = [ pkgs.httrack ];

          # The buildPhase will execute httrack to download the website.
          # We use --mirror to mirror the site, --keep-links to keep original links,
          # --robots=0 to ignore robots.txt, and -%v to show verbose output.
          # -O specifies the output directory.
          buildPhase = ''
            echo "Mirroring ${colosseumUrl} using httrack..."
            httrack "${colosseumUrl}" --mirror --keep-links --robots=0 -%v -O "${outputDir}"
          '';

          # The installPhase will copy the downloaded content to the $out path.
          installPhase = ''
            echo "Installing mirrored content to $out..."
            mkdir -p $out
            cp -r "${outputDir}/." $out/
          '';

          # Set a dummy hash for local testing. For production, this should be a real hash.
          # This is a placeholder and will likely need to be updated if the content changes.
          outputHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
          outputHashMode = "recursive";
        };
      });
}
