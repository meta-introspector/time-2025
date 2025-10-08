# CRQ 047: Proofs as Smart Contracts on a Sidechain

**Status:** Proposed

**Author:** Gemini

**Date:** 2025-10-07

## 1. Overview

This document proposes a system where running a proof is a smart contract on a sidechain that executes Lean4 in a secure Nix environment. This would provide a trustless, reproducible, and secure way to verify the correctness of software.

## 2. System Architecture

1.  **Proof as a Smart Contract:** Each proof would be represented as a smart contract on our sidechain. The smart contract would contain the Lean4 code for the proof, as well as the data to be verified.

2.  **Secure Nix Environment:** The smart contract would be executed in a secure Nix environment. This would ensure that the proof is executed in a reproducible and isolated environment, free from any external influences. The `mkLean4Spoke` function in `derivation-spokes.nix` could be used to create the Nix environment for running the Lean4 proofs.

3.  **Execution and Verification:** When the smart contract is executed, the Lean4 code is run against the data. If the proof succeeds, the smart contract would record the result on the sidechain. If the proof fails, the smart contract would record the failure.

4.  **Incentives:** The system could be designed to incentivize people to submit proofs and to verify them. For example, people who submit valid proofs could be rewarded with tokens on the sidechain. People who successfully challenge invalid proofs could also be rewarded.

## 3. Benefits

*   **Trustless Verification:** The system would provide a trustless way to verify the correctness of software. The verification would be done by a decentralized network of nodes, and the results would be recorded on an immutable ledger.
*   **Reproducibility:** The use of Nix would ensure that the verification is reproducible. Anyone could download the Nix environment and re-run the proof to get the same result.
*   **Security:** The use of a secure Nix environment would protect the verification process from malicious actors.
*   **Incentives:** The use of a token-based incentive system would encourage people to participate in the verification process.

## 4. Challenges

*   **Scalability:** Running a theorem prover like Lean4 on a blockchain could be computationally expensive. This could limit the scalability of the system.
*   **Complexity:** The system would be complex to design and implement. It would require expertise in a variety of fields, including blockchain, formal methods, and Nix.
*   **Adoption:** The system would need to be adopted by a critical mass of users in order to be successful.

## 5. Planning and Optimization with MiniZinc

A planning tool like MiniZinc can be used to calculate the best time and cost to run a proof. This would make the system more efficient and cost-effective.

1.  **Proof Submission with Constraints:** A user submits a proof to the system. The proof includes the Lean4 code, the data to be verified, and a set of constraints, such as a deadline or a budget.

2.  **Planning with MiniZinc:** The system uses a MiniZinc model to calculate the best time and cost to run the proof. The MiniZinc model would take into account a variety of factors, such as:
    *   The complexity of the proof.
    *   The current load on the sidechain.
    *   The user's constraints (deadline, budget).
    *   The availability of verifiers.
    *   The cost of running the proof on different verifiers.

3.  **Scheduling:** Once the MiniZinc model has found the optimal time and cost, the system schedules the execution of the smart contract on the sidechain.

This introduces a layer of resource optimization and scheduling that perfectly complements the trustless verification provided by the smart contracts. It connects directly to the work we've been doing with the OEIS solver and the `refineOeisSolverTask`, as we can adapt those concepts to create the MiniZinc model for proof scheduling.

## 6. Decentralized Planning and Model Submission

Any node in the system can propose the best model or plan for scheduling proofs. This would create a competitive market for models and plans, which would drive innovation and efficiency.

1.  **Model/Plan Submission:** Any node in the system can submit a model or plan for scheduling proofs. The model could be a MiniZinc model, a machine learning model, or any other type of model that can be used to predict the best time and cost to run a proof. The plan would be a concrete schedule of proofs to be executed.

2.  **Model/Plan Evaluation:** The system would evaluate the submitted models and plans based on a variety of criteria, such as:
    *   **Accuracy:** How well the model predicts the actual time and cost of running a proof.
    *   **Efficiency:** How well the plan utilizes the resources of the system.
    *   **Cost-Effectiveness:** How well the plan minimizes the cost of running proofs.

3.  **Model/Plan Selection:** The system would select the best model or plan based on the evaluation criteria. The selected model or plan would then be used to schedule the execution of proofs on the sidechain.

4.  **Incentives:** The system would incentivize nodes to submit high-quality models and plans. For example, nodes that submit models or plans that are selected by the system could be rewarded with tokens on the sidechain.

This creates a dynamic, self-optimizing system where the best strategies for scheduling and resource allocation can emerge from the network itself. It also connects to the agent portfolio concept, where agents could be the nodes submitting these models and plans.

## 7. Connection to Existing Work

This idea is a natural extension of the work we have been doing on `derivation-spokes.nix` and `hydra-p2p-scheduler.nix`. The `mkLean4Spoke` function in `derivation-spokes.nix` could be used to create the Nix environment for running the Lean4 proofs. The `hydra-p2p-scheduler.nix` could be used to schedule the execution of the smart contracts on the sidechain.
