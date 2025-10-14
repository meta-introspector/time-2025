# Flake Auditor Tool

## Purpose

The `flake_auditor` is a Rust-based command-line tool designed to audit Nix flake lock files (`flake.lock`). Its primary function is to identify and report any GitHub flake inputs that are not owned by the `meta-introspector` organization. This helps ensure compliance with project policies regarding external dependencies.

## Features

-   **Automated Discovery:** Automatically finds all `flake.lock` files within a specified root directory.
-   **GitHub Owner Verification:** Checks the `owner` field of each GitHub flake input against the `meta-introspector` organization.
-   **Graceful Error Handling:** Skips empty or malformed `flake.lock` files, printing a warning message without crashing.
-   **Clear Reporting:** Provides a clear output for each audited `flake.lock` file, listing any non-`meta-introspector` owners found.

## Building the Tool

The `flake_auditor` is a Rust crate and can be built using Cargo. It also has a Nix flake for reproducible builds.

### Using Cargo

To build the tool using Cargo, navigate to the `flake_auditor` directory and run:

```bash
cargo build --release
```

This will produce an optimized executable at `target/release/flake_auditor`.

### Using Nix Flake

To build the tool using Nix flakes, navigate to the `flake_auditor` directory and run:

```bash
nix build
```

This will build the tool and create a symlink to the executable in `./result/bin/flake_auditor`.

## Usage

Once built, the `flake_auditor` can be run from its executable path. It automatically globbs for `flake.lock` files starting from the project root (`/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/`) and audits each one.

```bash
/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/10/14/target/debug/flake_auditor
# Or, if built with Nix:
# ./result/bin/flake_auditor
```

### Example Output

```
--------------------------------------------------
Auditing /path/to/your/project/flake.lock:
Found flake inputs with owners other than 'meta-introspector':
- some-owner/some-repo (node: some-input)
- another-owner/another-repo (node: another-input)
--------------------------------------------------
Auditing /path/to/another/project/flake.lock:
All flake inputs are owned by 'meta-introspector'.
--------------------------------------------------
Auditing /path/to/empty/flake.lock:
Error parsing /path/to/empty/flake.lock: EOF while parsing a value at line 1 column 0
```

## Development

To enter a development shell with all necessary Rust tools (rustc, cargo, rustfmt, clippy), navigate to the `flake_auditor` directory and run:

```bash
nix develop
```
