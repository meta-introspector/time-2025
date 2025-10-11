# 2. The `nix-store-dump` Flake: The Core Wrapper

At the heart of our standardized NAR creation process is the `nix-store-dump` flake, located at `10/11/nix-store-dump/flake.nix`. This flake provides a simple, focused wrapper around the `nix-store --dump` command, abstracting away the direct shell command execution into a reusable Nix function.

## Purpose

The primary goal of the `nix-store-dump` flake is to encapsulate the raw `nix-store --dump` operation. It takes a Nix store path as input and produces a NAR file as its output, ensuring that the dumping process itself is standardized and easily callable from other Nix expressions.

## `lib.dumpStorePath` Function

This flake exposes a single, essential function: `lib.dumpStorePath`.

### Arguments:

*   `storePath` (required): The absolute path to the Nix store item (a file or directory) that you wish to convert into a NAR archive. This is typically a path like `/nix/store/...`.
*   `narFileName` (required): The desired filename for the resulting NAR archive. This name should include the `.nar` extension (e.g., `my-archive.nar`).

### How it Works:

The `dumpStorePath` function creates a Nix derivation (`pkgs.stdenv.mkDerivation`) that performs the following steps:

1.  **Build Phase:** Executes the `nix-store --dump ${storePath} > ${narFileName}` command. This command reads the content of the specified `storePath` and writes it as a NAR archive to a temporary file named `narFileName` within the derivation's build environment.
2.  **Install Phase:** Moves the newly created `narFileName` into the `$out` directory of the derivation. This means that the final output of this derivation will be the NAR file itself, located at `$(nix build .#dumpStorePath --argstr storePath ... --argstr narFileName ...)`.

## Benefits:

By using this wrapper, we ensure that the fundamental NAR creation step is consistent across the project. It separates the concern of *how* a NAR is created from *where* it is stored and *what* it is named, which are handled by the next layer of abstraction: the `nar-locator` flake.
