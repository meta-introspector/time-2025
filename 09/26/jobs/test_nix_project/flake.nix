{
  description = "A temporary Nix project";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
  };

  outputs = { self, nixpkgs }: {
    packages.x86_64-linux.my-network-test-package = nixpkgs.legacyPackages.x86_64-linux.stdenv.mkDerivation {
      pname = "my-network-test-package";
      version = "0.1.0";
      src = ./.;
      buildInputs = [ nixpkgs.legacyPackages.x86_64-linux.curl ];
      buildPhase = ''
        echo "Attempting to fetch example.com"
        curl -o output.html https://example.com
        echo "Fetched example.com"
      '';
      installPhase = ''
        mkdir -p $out/share/my-network-test-package
        cp output.html $out/share/my-network-test-package/
      '';
    };
  };
}
