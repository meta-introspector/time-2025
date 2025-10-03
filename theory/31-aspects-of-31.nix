# theory/31-aspects-of-31.nix
{ lib, pkgs, ... }:

let
  aspectsOf31 = {
    "01-Purity" = "The foundational principle of Nix, ensuring builds are isolated and free from external influences.";
    "02-Reproducibility" = "Every Nix build, given the same inputs, will produce the exact same output, byte for byte.";
    "03-Determinism" = "The predictable outcome of Nix builds, a direct result of its functional nature.";
    "04-Immutability" = "Nix store paths are immutable; once built, they cannot be changed, ensuring stability.";
    "05-Derivations" = "The core unit of computation in Nix, defining how a package is built.";
    "06-Flakes" = "The modern, self-contained, and reproducible way to manage Nix projects and their dependencies.";
    "07-NixStore" = "The content-addressed, immutable storage system where all built artifacts reside.";
    "08-GarbageCollection" = "The mechanism to remove unreferenced paths from the Nix store, reclaiming space.";
    "09-NixBuild" = "The command-line utility to realize derivations and build packages.";
    "10-NixShell" = "Creating isolated development environments with specific dependencies.";
    "11-NixInstantiate" = "Evaluating Nix expressions to produce derivations or other Nix values.";
    "12-NixStoreQueryRoots" = "Inspecting the garbage collection roots to understand what keeps paths alive.";
    "13-Nixpkgs" = "The vast collection of Nix expressions for building thousands of software packages.";
    "14-OverrideAttrs" = "Customizing the attributes of an existing package derivation.";
    "15-MkDerivation" = "The primary function used to define a derivation in Nix.";
    "16-CallPackage" = "A helper function to instantiate packages from nixpkgs, automatically passing common arguments.";
    "17-Lib" = "The Nix standard library, providing a rich set of utility functions for Nix expressions.";
    "18-Builtins" = "Functions provided directly by the Nix evaluator, available without explicit import.";
    "19-EvalModules" = "The mechanism for composing NixOS configurations from modular definitions.";
    "20-DevShell" = "A specific output of a flake defining a development environment.";
    "21-Outputs" = "The attribute set returned by a flake, containing packages, devShells, and other definitions.";
    "22-Inputs" = "The dependencies of a flake, typically other flakes or Git repositories.";
    "23-System" = "The target system architecture (e.g., 'x86_64-linux', 'aarch64-darwin').";
    "24-Pkgs" = "The package set, usually obtained from nixpkgs, containing all available packages for a system.";
    "25-Overlays" = "A way to extend or modify the package set provided by nixpkgs.";
    "26-Modules" = "Declarative configuration units used in NixOS and home-manager.";
    "27-ConfigurationNix" = "The central file for defining a NixOS system configuration.";
    "28-HomeManager" = "A Nix module system for managing user-specific configurations declaratively.";
    "29-NixDaemon" = "The background service that performs Nix builds, often running as root.";
    "30-Hash" = "The cryptographic hash used for content-addressing in the Nix store.";
    "31-FixedOutputDerivations" = "Derivations whose output is known beforehand, typically used for fetching external sources.";
  };
in
aspectsOf31