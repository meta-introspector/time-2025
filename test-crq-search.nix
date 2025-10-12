{
  description = "Temporary flake for testing crq-search.nix";

  inputs = {
    streamofrandom.url = "github:meta-introspector/streamofrandom?ref=feature/foaf"; # Reference the main flake
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
  };

  outputs = { self, streamofrandom, nixpkgs, ... }:
    let
      system = "aarch64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      apps.${system}.default = {
        type = "app";
        program = "${pkgs.writeShellScript "crq-search-test" ''
          echo "--- Running CRQ Search Test from temporary flake ---"
          nix eval --json --expr 'builtins.getFlake (toString ./.).inputs.streamofrandom.lib.crqSearch { keyword = "Log Analysis"; }'
          echo "--- CRQ Search Test Complete ---"
        ''}";
      };
    };
}
