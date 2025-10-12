# Data Header Nix Flake

This Nix flake provides a mechanism to wrap various data files (initially `.nix` files) as Nix packages, making their content easily accessible and addressable within the Nix ecosystem. It also demonstrates how to create executable applications that interact with these data packages.

## Features

*   **Data File Packaging:** Automatically discovers and packages `.nix` files from the `data/` directory into individual Nix derivations.
*   **Meta-Package:** Provides a `default` package that aggregates all individual data packages.
*   **Plato's Wisdom Emitter App:** An example application (`platos-wisdom-emitter`) that demonstrates how to access and process the content of a specific data file (`platos-mountain.nix`).

## Usage

### Accessing Data Packages

Each `.nix` file in the `data/` directory is exposed as a separate package. For example, to access the `platos-mountain.nix` content:

```bash
nix build .#platos-mountain-data
# The content of platos-mountain.nix will be available in the resulting /nix/store path.
# You can inspect it using:
# cat $(nix build .#platos-mountain-data --no-link --print-out-paths)/share/platos-mountain/data.json
```

### Running the Plato's Wisdom Emitter App

The `platos-wisdom-emitter` app evaluates the `platos-mountain.nix` file and outputs its content as JSON.

```bash
nix run .#platos-wisdom-emitter
```

### Vision: Wrapping Other File Types as Virtual Flakes

This flake lays the groundwork for a broader vision: to treat various file types (Rust source files, Markdown documents, etc.) as "virtual flakes" or addressable Nix derivations.

Imagine being able to:

*   **Nixify Rust files:** Automatically compile and package Rust crates or even individual Rust files as Nix derivations, making them instantly buildable and shareable.
*   **Nixify Markdown files:** Process Markdown documents to generate HTML, PDF, or other formats, or extract metadata, all managed by Nix.
*   **Unified Content Addressing:** Every significant file in your project could have a unique Nix address, allowing for powerful dependency management, caching, and reproducible builds across diverse content types.

This approach aims to extend the benefits of Nix's reproducibility and declarative nature beyond traditional software packages to all forms of digital assets and content.
