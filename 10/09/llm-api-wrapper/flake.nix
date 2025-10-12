{
  description = "Dummy LLM API wrapper flake for testing.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
  };

  outputs = { self, nixpkgs }:
    let
      pkgs = nixpkgs.legacyPackages.aarch64-linux;
    in
    {
      packages.aarch64-linux.default = pkgs.runCommand "dummy-llm-api-wrapper"
        {
          buildInputs = [ pkgs.bash ];
        } ''
        mkdir -p $out/bin
        echo '#!${pkgs.bash}/bin/bash' > $out/bin/call-llm-api
        echo 'echo "{\"tasks\": [{\"id\": 1, \"description\": \"Task 1\", \"duration\": 5, \"dependencies\": [], \"resources\": [\"LLM\"]}]}"' >> $out/bin/call-llm-api
        chmod +x $out/bin/call-llm-api
      '';
    };
}
