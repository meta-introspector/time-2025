{
  description = "Dummy Solana Nix package for testing.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
  };

  outputs = { self, nixpkgs }:
    let
      pkgs = nixpkgs.legacyPackages.aarch64-linux;
    in
    {
      packages.aarch64-linux.default = pkgs.runCommand "dummy-solana-tools" {
        buildInputs = [ pkgs.bash ];
      } ''
        mkdir -p $out/bin
        echo '#!${pkgs.bash}/bin/bash' > $out/bin/solana-cli
        echo 'echo "Dummy Solana CLI output for command: $1, config: $2" >&2' >> $out/bin/solana-cli
        echo 'echo "market_id: 1234567890"' >> $out/bin/solana-cli
        chmod +x $out/bin/solana-cli
      '';
    };
}