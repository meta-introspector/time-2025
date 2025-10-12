{
  description = "Dummy GitHub API wrapper flake for testing.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
  };

  outputs = { self, nixpkgs }:
    let
      pkgs = nixpkgs.legacyPackages.aarch64-linux;
    in
    {
      packages.aarch64-linux.default = pkgs.runCommand "dummy-github-api-wrapper"
        {
          buildInputs = [ pkgs.bash ];
        } ''
        mkdir -p $out/bin
        echo '#!${pkgs.bash}/bin/bash' > $out/bin/fetch-github-data
        echo 'echo "Dummy GitHub data for repo: $1, token: $2" >&2' >> $out/bin/fetch-github-data
        echo 'echo "{\"issues\": [{\"id\": 1, \"title\": \"Dummy Issue\"}], \"pull_requests\": []}"' >> $out/bin/fetch-github-data
        chmod +x $out/bin/fetch-github-data
      '';
    };
}
