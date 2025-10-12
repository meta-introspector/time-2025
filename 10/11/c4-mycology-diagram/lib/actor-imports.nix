{ lib }: {
  aimyceliumActor = import ../actors/aimycelium.nix { inherit lib; };
  gitActor = import ../actors/git.nix { inherit lib; };
  nixstoreActor = import ../actors/nixstore.nix { inherit lib; };
  ipfsActor = import ../actors/ipfs.nix { inherit lib; };
  solanaActor = import ../actors/solana.nix { inherit lib; };
}
