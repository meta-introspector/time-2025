{
  description = "Type check for flake compatibility";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";

    # The two flakes to be checked
    providerFlake.url = "path:../../../dwim"; # dwimFlake
    consumerFlake.url = "path:../../tasks/act"; # actFlake
  };

  outputs = { self, nixpkgs, flake-utils, providerFlake, consumerFlake }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        checks.default = pkgs.runCommand "type-compatibility-check"
          {
            nativeBuildInputs = [ pkgs.jq ];
          } ''
          provider_report=${providerFlake.packages.${system}.typeReport}
          consumer_report=${consumerFlake.packages.${system}.typeReport}

          echo "--- Running Type Compatibility Check ---"
          echo "Provider (dwimFlake) Report:"
          cat $provider_report
          echo ""
          echo "Consumer (actFlake) Report:"
          cat $consumer_report
          echo ""

          # The path the consumer (actFlake) expects for the dwim tool
          # from the provider's output structure.
          check_expr='.outputs.lib.attrs."${system}".attrs.dwim'

          if jq -e "$check_expr" $provider_report > /dev/null; then
            echo "OK: Provider has the structure expected by the consumer."
            touch $out
          else
            echo "FAIL: Type Mismatch!"
            echo "Consumer expects a 'dwim' attribute at: .lib.${system}.dwim"
            echo "But the provider does not offer this structure in its outputs."
            exit 1
          fi
        '';
      });
}
