{ lib, pkgs }:
{
  name = "reward-earning-spec";
  description = "Specification for a task that allows a miner to claim rewards based on successfully published and verified LLM results.";
  taskType = "earning";
  inputs = {
    solanaTransactionId = "The Solana transaction ID from the /publish task.";
    minerWalletAddress = "The miner's wallet address.";
    qaReport = "The QA report to verify eligibility for rewards.";
  };
  outputs = {
    rewardClaimStatus = "A derivation containing the status of the reward claim.";
  };
}
