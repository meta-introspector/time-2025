{
  description = "A generic bridge flake that connects a producer and a consumer.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs/26833ad1dad83826ef7cc52e0009ca9b7097c79f";
    producer.flake = true;
    consumer.flake = true;
  };

  outputs = { self, nixpkgs, producer, consumer }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      producer-output = producer.packages.x86_64-linux.default;
    in
    {
      packages.x86_64-linux.default = consumer.packages.x86_64-linux.default.override {
        hackathon-status-raw = producer-output;
      };
    };
}
