{
  description = "Nix flake for the CRQ document check script.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
  };

  outputs = { self, nixpkgs }:
    let
      system = "aarch64-linux"; # Hardcode system as per user instruction
      pkgs = import nixpkgs { inherit system; };
    in
    {
      packages.${system}.crq-document-check-script = pkgs.writeShellScriptBin "crq-document-check" ''
        COMMIT_MSG_FILE="$1"
        NIX_OUTPUT=$(${pkgs.nix}/bin/nix eval --json --arg pkgs ${nixpkgs} --arg crqCheckLib ${./../10/04/lib/crq-document-check.nix} --argstr commitMsgFile "$COMMIT_MSG_FILE" --expr 'let pkgs = import pkgs {}; in import crqCheckLib { inherit pkgs; commitMsgFile = commitMsgFile; }')
        SUCCESS=$(echo "$NIX_OUTPUT" | ${pkgs.jq}/bin/jq -r '.success')
        MESSAGE=$(echo "$NIX_OUTPUT" | ${pkgs.jq}/bin/jq -r '.message')

        if [ "$SUCCESS" = "false" ]; then
          echo "$MESSAGE" >&2
          exit 1
        else
          exit 0
        fi
      '' {
        buildInputs = [ pkgs.nix pkgs.jq ];
      };
    };
}