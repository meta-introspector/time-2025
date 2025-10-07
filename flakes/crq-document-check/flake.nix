{
  description = "Nix flake for the CRQ document check script.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    mainProject.url = "github:meta-introspector/time-2025?ref=feature/foaf"; # Reference the main project flake
  };

  outputs = { self, nixpkgs, mainProject }:
    let
      system = "aarch64-linux"; # Hardcode system as per user instruction
      pkgs = import nixpkgs { inherit system; };
    in
    {
      packages.${system} = {
        evaluate-nix-expression-script = pkgs.writeShellScriptBin "evaluate-nix-expression" {
          buildInputs = [ pkgs.nix ];
        } (builtins.readFile ./evaluate-nix-expression.sh);

        eval-crq-check-script = pkgs.writeShellScriptBin "eval-crq-check" {
          buildInputs = [ pkgs.nix pkgs.jq ];
          nixpkgsPath = nixpkgs; # Pass nixpkgs as a build input
          crqCheckLibPath = "github:meta-introspector/time-2025?ref=feature/foaf&dir=10/04/lib/crq-document-check.nix"; # Pass crqCheckLib as a build input
        } ''
          COMMIT_MSG_FILE="$1"

          NIX_OUTPUT=$(${pkgs.nix}/bin/nix eval --json --arg pkgs "$nixpkgsPath" --arg crqCheckLib "$crqCheckLibPath" --argstr commitMsgFile "$COMMIT_MSG_FILE" --expr 'let pkgs = import pkgs {}; in import crqCheckLib { inherit pkgs; commitMsgFile = commitMsgFile; }')

          SUCCESS=$(echo "$NIX_OUTPUT" | ${pkgs.jq}/bin/jq -r '.success')
          MESSAGE=$(echo "$NIX_OUTPUT" | ${pkgs.jq}/bin/jq -r '.message')

          if [ "$SUCCESS" = "false" ]; then
            echo "$MESSAGE" >&2
            exit 1
          else
            exit 0
          fi
        '';

        run-crq-check-script = pkgs.writeShellScriptBin "run-crq-check" {
          buildInputs = [ pkgs.nix pkgs.jq ];
        } (builtins.readFile ./run-crq-check.sh);

        crq-document-check-script = pkgs.writeShellScriptBin "crq-document-check" {
          buildInputs = [ pkgs.nix ]; # Only nix is needed here to build the run-crq-check-script
        } ''
          COMMIT_MSG_FILE="$1"
          RUN_CRQ_CHECK_SCRIPT=$(${pkgs.nix}/bin/nix build .#packages.${system}.run-crq-check-script --no-link --print-out-paths)
          "$RUN_CRQ_CHECK_SCRIPT/bin/run-crq-check" \
            --nixpkgs-path ${nixpkgs} \
            --crq-check-lib-path "github:meta-introspector/time-2025?ref=feature/foaf&dir=10/04/lib/crq-document-check.nix" \
            --commit-msg-file "$COMMIT_MSG_FILE"
        '';
      };
    };
}