{ lib, pkgs }:
{
  name = "result-publishing-spec";
  description = "Specification for a task that publishes verified LLM results to distributed storage (e.g., IPFS) and records references on a blockchain (e.g., Solana).";
  taskType = "publishing";
  inputs = {
    verifiedResults = "A derivation containing the verified LLM results from the /qa task.";
    qaReport = "The QA report for auditing purposes.";
    blockchainCredentials = "Credentials for interacting with the blockchain.";
  };
  outputs = {
    ipfsHash = "A derivation containing the IPFS hash of the published results.";
    solanaTransactionId = "A derivation containing the Solana transaction ID for the rollup.";
  };
}
