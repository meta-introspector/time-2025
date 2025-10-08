# Stream of Random (2025)

This repository is a core component of the `solfunmeme` project, focusing on the continuous integration and evolution of digital alife and meme mycology through a highly structured and introspective development process. It embodies the principles of the `bott` Universal Architectural Framework and operates within an OODA Loop of Self-Introspection.

## Architectural Vision: OODA Loop of Self-Introspection

The project's architecture is designed as a closed-loop system for continuous self-improvement and validation:

*   **Observe:** Comprehensive indexing of Nix-orchestrated builds via low-level execution traces (strace, perf, ebpf, telemetry, objdump, addr2line).
*   **Orient:** Mapping observed content to the project's meta-model (bott framework, Monster Group, CRQs, formal ontologies) for harmony and validation.
*   **Decide:** Applying rules and validating via MiniZinc and Lean4 to ensure consistency, adherence to design principles, and verification of actual system behavior against intended design and safety properties.
*   **Act:** Subsequent actions based on validation results, leading to system evolution and refinement.

## Nixification (CRQ-016)

We are actively engaged in Nixification efforts (CRQ-016) to ensure:

*   **Purity:** Nix builds read inputs from the store and write outputs to the store, guaranteeing reproducibility.
*   **Reproducibility:** Consistent build environments and deterministic outputs across all development stages.
*   **Standardization:** Uniform management of dependencies and build processes across all project components and submodules.

## Setup

To set up the project, ensure you have Nix installed. Then, clone the repository and its submodules. For a comprehensive setup, including pre-commit hooks and Nix environment configuration, it is highly recommended to use the `onboard_project.sh` script.

```bash
git clone https://github.com/meta-introspector/streamofrandom.git
cd streamofrandom/2025
git submodule update --init --recursive
./scripts/onboard_project.sh
pre-commit install
```

## Usage

(Further usage instructions will be added here as the project evolves.)


## Testing Specific Flakes

To run tests for specific flakes, navigate to the flake's directory and use its `Makefile` (if available) or directly use `nix build` or `nix flake check`.

For example, to test the `build-time-gemini-telemetry` flake:

```bash
cd 09/27/7-concepts/6-qa-testing/tests/2025-01-27-build-time-gemini-capture/
make test
make build
```

And to test the `consolidated-impure-gemini-telemetry` flake:

```bash
nix build 09/27/7-concepts/6-qa-testing/tests/consolidated-impure-gemini-telemetry/#default --extra-experimental-features "nix-command flakes impure-derivations ca-derivations"
```

Alternatively, you can run all QA flake tests from the project root:

```bash
make test-qa-flakes
```

## Code Quality

We use `statix` for linting and static analysis of Nix expressions to ensure code quality and adherence to our architectural principles.

To run the Nix linter and generate a detailed report:

```bash
make lint-nix
```

This command will run `statix` on all Nix files, save the output to `statix_output.txt`, and then split this file into smaller, manageable parts (e.g., `statix_output_part_aa`, `statix_output_part_ab`).

## Documentation

Our comprehensive documentation covers various aspects of the project, including CRQs, SOPs, and tutorials.

*   **CRQs (Change Request Documents):** `docs/crqs/`
*   **SOPs (Standard Operating Procedures):** `docs/sops/`
*   **Tutorials & Guides:** `docs/tutorials/`
    *   `docs/tutorials/Onboarding_Guide_for_Nix_Newcomers.md`
    *   `docs/tutorials/Contributing_with_CRQs_and_SOPs.md`
    *   `docs/Nix_and_Precommit_Setup.md`
    *   `docs/sops/SOP_Running_Nix_Tools.md`

## Contributing (CRQ-017)

We welcome contributions! Please refer to our [Onboarding Guide for Nix Newcomers](docs/tutorials/Onboarding_Guide_for_Nix_Newcomers.md) and [Contributing with CRQs and SOPs](docs/tutorials/Contributing_with_CRQs_and_SOPs.md) for detailed guidelines.

