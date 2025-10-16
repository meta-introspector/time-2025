{
  description = "A micro flake to cat a specific flake.nix from the Nix store.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify"; # Use project's standard nixpkgs input
  };

  outputs = { self, nixpkgs }:
    let
      system = "aarch64-linux"; # Assuming aarch64-linux as per previous interactions
      pkgs = nixpkgs.legacyPackages.${system}; # Use nixpkgs from the input
    in
    {
      packages.${system}.default = pkgs.runCommand "nix-store-flake-lock-finder"
        {
          buildInputs = [ pkgs.findutils pkgs.jq ]; # For 'find' and 'jq'
        } ''
        mkdir -p $out
        # WARNING: This command makes the derivation impure as it directly accesses /nix/store.
        # The output of this derivation will depend on the dynamic state of the Nix store
        # at build time, making it non-reproducible in a strict sense.
        find /nix/store -type f -name "flake.lock" | jq -Rsc . > $out/flake-lock-index.json
      '';

      apps.${system}.default = {
        type = "app";
        program = "${pkgs.writeShellScript "run-flake-lock-finder" ''
          cat ${self.packages.${system}.default}/flake-lock-index.json
        ''}";
      };
    };
}
