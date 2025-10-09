{
  description = "An instance of the bridge flake, connecting the colosseum producer and consumer.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs/26833ad1dad83826ef7cc52e0009ca9b7097c79f";
    bridge-pattern = {
      url = "github:meta-introspector/time-2025?ref=feature/lattice-30030-homedir&dir=10/09/hackathon/bridge-pattern";
      flake = true;
    };
    colosseum-producer = {
      url = "github:meta-introspector/time-2025?ref=feature/lattice-30030-homedir&dir=10/09/hackathon/colosseum";
      flake = true;
    };
    hackathon-consumer = {
      url = "github:meta-introspector/time-2025?ref=feature/lattice-30030-homedir&dir=10/09/hackathon/consumer";
      flake = true;
    };
  };

  outputs = { self, nixpkgs, bridge-pattern, colosseum-producer, hackathon-consumer }:
    bridge-pattern.outputs {
      inherit nixpkgs;
      producer = colosseum-producer;
      consumer = hackathon-consumer;
    };
}
