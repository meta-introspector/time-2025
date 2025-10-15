{ lib, pkgs }:
{
  name = "zkp-proof-task-spec";
  description = "Specification for a task that generates a Zero-Knowledge Proof (ZKP) for the input/output validity of a Nix flake based on type commitments.";
  taskType = "zkp-proof";
  inputs = {
    flakePath = "The absolute path to the flake.nix file to prove.";
    typeCommitment = "A derivation representing the type commitment for the flake's interface.";
    # Potentially other inputs like a ZKP circuit definition
  };
  outputs = {
    zkpProof = "A derivation containing the generated Zero-Knowledge Proof.";
    proofVerificationKey = "A derivation containing the public verification key for the proof.";
  };
}
