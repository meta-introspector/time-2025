# Monster Experiment: Four Core Elements

This document outlines the four core architectural elements of the "Monster Experiment" for Wikidata extraction and NAR compilation, emphasizing the distinction between pure and impure Nix processes.

## 1. Pure Nix Rust Build

The `rust_knowledge_extractor` crate, responsible for fetching and processing web content, will be built in a **pure** Nix environment. This ensures that the Rust binary itself is reproducible and hermetic. This involves:
*   Utilizing `naersk` (or `pkgs.rustPlatform.buildRustPackage`) for building the Rust project.
*   Properly configuring `fetchCargoVendor` with a fixed `sha256` hash to ensure all Rust dependencies are fetched and managed purely by Nix.

## 2. Impure Usage of Rust Crate for Data Download and Storage

The purely built `rust_knowledge_extractor` binary will be executed in an **impure** environment. This impurity is necessary to allow network access for downloading data (e.g., from Wikidata). The output of this step will be structured data (e.g., JSON), which will then be stored, potentially as a Nix Archive (NAR) data flake.

## 3. Pure Gemini Build

Any `gemini-cli` flake or other Gemini-related tools involved in the experiment will also be built in a **pure** Nix environment. This ensures the reproducibility and integrity of the LLM interaction tools themselves.

## 4. Impure Usage of Gemini Nix with Data Nix to Create New Derived Data Nix

The purely built `gemini-cli` (from element 3) will be used in an **impure** environment. This impure execution will:
*   Take the downloaded and stored data (from element 2, likely as a NAR data flake) as input.
*   Access credentials and interact with the LLM via its API.
*   Produce a new derived Nix Archive (NAR) file data flake, representing the telemetry trace or processed output from the LLM interaction. This approach allows for a "semi-stable derivation," where the LLM interaction itself is impure, but its inputs and outputs are versioned and managed by Nix.
