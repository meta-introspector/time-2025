# Nix Examples

This directory contains example Nix expressions.

## eval-mini-prelude.nix

This file demonstrates how to evaluate the `mini-prelude.nix` expression. It imports `mini-prelude.nix` and calls it with `pkgs` and `lib` from `nixpkgs`. The output of this expression is a JSON array of file paths, which can be used for further processing.

To evaluate this example, you can use the following command:

```bash
nix-instantiate --eval --json eval-mini-prelude.nix
```
