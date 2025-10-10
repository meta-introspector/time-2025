{
  description = "A test flake to build the nar flake";

  inputs = {
    nar-flake.url = "../../lib/nar";
  };

  outputs = { self, nar-flake }:
    let
      system = "aarch64-linux";
    in
    {
      packages.${system}.default = nar-flake.packages.${system}.default;
    };
}
