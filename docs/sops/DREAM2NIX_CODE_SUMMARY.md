# Dream2nix Code Summary

This document summarizes the `dream2nix` codebase as I explore it to fix `statix` warnings.

## Flake Structure (`examples/packages/languages/rust-local-development-workspace/flake.nix`)

The `flake.nix` files in the `dream2nix` examples demonstrate a common pattern for defining packages. Here's a breakdown of the key components:

- **Inputs:** The flakes take `dream2nix` and `nixpkgs` as inputs. They use the `follows` feature to ensure that the `nixpkgs` revision is the same as the one used by `dream2nix`.
- **`eachSystem`:** A helper function is used to generate packages for all supported systems (`aarch64-darwin`, `aarch64-linux`, `x86_64-darwin`, `x86_64-linux`).
- **`dream2nix.lib.evalModules`:** This is the core function for evaluating a dream2nix package. It takes a set of modules as input and returns a derivation.
- **Modules:** The modules passed to `evalModules` define the package. This typically includes:
    - The main package definition (e.g., `./default.nix`).
    - A module to configure the project paths (`projectRoot`, `projectRootFile`, `package`). This allows `dream2nix` to find the source code and other project files.
    - **`paths` Configuration:** The `paths` attribute set is used to specify the location of the project root, the main project file, and the package itself. To avoid `statix` W20 warnings ("Avoid repeated keys in attribute sets"), these should be defined as a single attribute set rather than repeated assignments (e.g., `paths = { projectRoot = ./.; ... };` instead of `paths.projectRoot = ./.;`).

## `mkDerivation` Module (`modules/dream2nix/mkDerivation/default.nix`)

This module provides a `dream2nix` interface to the standard `stdenv.mkDerivation`. It allows you to use `mkDerivation` within the `dream2nix` framework.

- **Imports:** It imports several other modules, including `package-func`, `deps`, `env`, and `ui`.
- **`package-func`:** It configures the `package-func` module to use `stdenv.mkDerivation` as the builder function.
- **`public`:** It exposes the `meta` and `tests` attributes of the derivation.
- **`deps`:** It defines a dependency on `stdenv` from `nixpkgs`.
- **Environment Variable Checks:** It includes a check to prevent collisions between environment variables (`config.env`) and `mkDerivation` attributes.

## `statix` Fixes and Code Model Insights

During the process of fixing `statix` warnings, several common patterns and best practices in Nix module authoring within `dream2nix` became apparent.

### W20: Avoid repeated keys in attribute sets
This warning indicates that attributes within a set are being assigned individually (e.g., `attr.subAttr1 = val1; attr.subAttr2 = val2;`) instead of being grouped into a single attribute set (e.g., `attr = { subAttr1 = val1; subAttr2 = val2; };`).

**Impact on `dream2nix`:** This pattern was frequently observed in `flake.nix` files for `paths` configurations and in module definitions for `config.package-func` and `public` attribute sets. Refactoring these into single attribute sets improves readability and adheres to Nix best practices.

### W03: Assignment instead of inherit
This warning suggests using `inherit` when an attribute is assigned to a variable with the same name (e.g., `foo = foo;` should be `inherit foo;`).

**Impact on `dream2nix`:** This was found in `modules/dream2nix/mkDerivation/default.nix` and `modules/dream2nix/core/lock/default.nix` for `public = public;` and `isValid = isValid;` respectively. Using `inherit` makes the code more concise.

### W04: Assignment instead of inherit from
Similar to W03, this warning applies when an attribute is assigned from another attribute set with the same name (e.g., `foo = bar.foo;` should be `inherit (bar) foo;`).

**Impact on `dream2nix`:** This was seen in `modules/dream2nix/core/ui/default.nix` (`drvPath = config.public.drvPath;`), `modules/dream2nix/mkDerivation/default.nix` (`outputs = cfg.outputs;`), `modules/dream2nix/python-pdm/default.nix` (`name = pyproject.pyproject.project.name;`, `file = source.file;`, `hash = source.hash;`), and `modules/dream2nix/builtins-derivation/default.nix` (`outputs = cfg.outputs;`). Adopting `inherit (attrSet) attr;` improves clarity and conciseness.

### W08: These parentheses can be omitted
This warning points out redundant parentheses that do not affect the parsing or evaluation of the expression.

**Impact on `dream2nix`:** Found in `modules/dream2nix/python-pdm/default.nix` within complex `lib.attrValues` and conditional expressions. Removing these parentheses simplifies the expressions.

### W11: Found redundant pattern bind in function argument
This warning occurs when a function argument uses a pattern bind (e.g., `{...} @ var:`) but the `var` itself is sufficient (e.g., `var:`).

**Impact on `dream2nix`:** Observed in `modules/dream2nix/python-pdm/default.nix` in a `module = {...} @ depConfig:` definition. Simplifying this to `module = depConfig:` makes the function signature cleaner.

### W19: This `if` expression can be simplified with `or`
This warning suggests replacing `if ... then ... else ...` constructs with the `or` operator when applicable, typically for default value assignments.

**Impact on `dream2nix`:** Encountered in `modules/dream2nix/python-pdm/default.nix` for version assignment. Using `or` makes the code more idiomatic and concise for such cases.

These `statix` fixes collectively contribute to a more readable, maintainable, and idiomatic Nix codebase for `dream2nix`, aligning with general Nix best practices.