#!/usr/bin/env bash

set -euo pipefail

PROJECT_ROOT="/data/data/com.termux.nix/files/home/pick-up-nix2"

# Function to build a Rust crate within its directory
build_rust_crate() {
    local crate_path="$1"
    local crate_name="$2"
    local is_bin="$3"

    echo "--- Building $crate_name with Cargo ---"
    ( 
        cd "$PROJECT_ROOT/$crate_path"
        if [ "$is_bin" = "true" ]; then
            cargo build --release --bin "$crate_name"
        else
            cargo build --release
        fi
    )
    echo "--- Build of $crate_name complete ---"
}

# Build rnix-eval
build_rust_crate "vendor/nix/rnix-eval" "rnix-eval" "false"

# Placeholder for rnix-parser-tester sub-crates (will be called later)
# build_rust_crate "vendor/nix/rnix-parser-tester/crates/cli" "cli" "true"
# build_rust_crate "vendor/nix/rnix-parser-tester/crates/normal-ast" "normal-ast" "false"
# build_rust_crate "vendor/nix/rnix-parser-tester/crates/ref-impl-parser" "ref-impl-parser" "false"
# build_rust_crate "vendor/nix/rnix-parser-tester/crates/rnix-ast" "rnix-ast" "false"
# build_rust_crate "vendor/nix/rnix-parser-tester/crates/rnix-normalize" "rnix-normalize" "false"