# CRQ-046: Leverage Existing Wikidata Extractor for Structured Prefetching

## 1. Introduction

This Change Request outlines a revised approach to prefetching OWL, Wikidata, and Wikipedia articles in a structured manner. Initial investigations into generic prefetch/fetch Nix flakes (like `nurl`, `nix-universal-prefetch`) revealed that while they can fetch raw URLs, they do not inherently provide the "structured manner" processing required.

Further analysis of the project's existing codebase, specifically `~/nix/index/chunks/wikidata.txt`, `~/nix/index/chunks/wikipedia.txt`, and `~/nix/index/chunks/oeis.txt`, has revealed that the project already contains dedicated Rust-based extractors and automation for these data sources. This existing infrastructure includes client interaction, parsing capabilities, and formal CRQs (e.g., `CRQ-059` for Wikipedia/Wikidata extraction, `CRQ_INTROSPECTION_SEQUENCES_OEIS_20250903.md` for OEIS).

This CRQ proposes to leverage this existing infrastructure rather than developing new fetchers from scratch, thereby aligning with existing project conventions and accelerating development.

## 2. Goals

*   To efficiently prefetch OWL, Wikidata, and Wikipedia articles.
*   To efficiently prefetch OEIS data.
*   To utilize existing project code and infrastructure for parsing and structuring fetched data.
*   To integrate the existing `git-submodules-rs-nix/tools/wikidata` project and OEIS-related Rust code into the broader Nix flake ecosystem.
*   To ensure a structured output of fetched data that can be consumed by other Nix modules or project components.

## 3. Revised Plan

The following steps will be undertaken to achieve the goals:

### 3.1. External Dependency Integration Policy

Adhere to the new project-wide policy for external dependency integration:
- **Integration Method:** All external dependencies are to be integrated via `github:meta-introspector` URLs.
- **Submodule Usage:** Submodules are *not* to be used for general integration of external dependencies. Their use is strictly reserved for scenarios involving *editing, pushing, and tagging* of those external repositories.
- **Assumption:** It is expected that all necessary external dependencies are already checked in and labeled within the `github:meta-introspector` organization.

### 3.2. Create a New Flake for Custom Fetchers

Create a new flake, `meta-introspector-fetchers`, to house specialized fetchers for Wiki, OEIS, and OpenStreetMap data. This flake will be located at `10/06/meta-introspector-fetchers/flake.nix`.

### 3.3. Integrate `git-submodules-rs-nix` as a Flake Input

Add `git-submodules-rs-nix` as an input to the `meta-introspector-fetchers` flake. The URL for this input will be `github:meta-introspector/git-submodules-rs-nix`.

### 3.4. Implement `fetchWiki` (for Wikipedia/Wikidata)

*   **Build `git-submodules-rs-nix/tools/wikidata` using `naersk`:** Add `naersk` as an input to the `meta-introspector-fetchers` flake and use it to build the Rust project located at `git-submodules-rs-nix/tools/wikidata`. This will make its executables (e.g., `wikipedia_parser`, `wikidata_client`) available.
*   **Create a Nix function `fetchWiki`:** This function will leverage the built Rust executables to fetch and process Wikipedia/Wikidata articles. It will use `builtins.fetchurl` internally to retrieve raw content and then invoke the Rust tool for parsing and structuring.

### 3.5. Implement `fetchOeis`

*   **Identify OEIS Rust code:** Locate and integrate the existing OEIS Rust code (e.g., `oeis.rs`, `oeis_quasifibers.rs` from `bootstrap`/`lattice-introspector`) into the `meta-introspector-fetchers` flake, building it with `naersk`.
*   **Create a Nix function `fetchOeis`:** This function will leverage the built OEIS Rust executables and potentially existing automation scripts (e.g., `generate_oeis_index.sh`) to fetch and process OEIS data. It will also use `builtins.fetchurl` or similar for raw data retrieval.

### 3.6. Integrate `meta-introspector-fetchers` into the Aggregation Flake

Add the new `meta-introspector-fetchers` flake as an input to the main aggregation flake (`/data/data/com.termux.nix/files/home/nix/vendor/nix/flake.nix`). Expose `fetchWiki` and `fetchOeis` as outputs of the aggregation flake.

### 3.7. Later: Implement OpenStreetMap Fetchers

Extend the `meta-introspector-fetchers` flake to include OpenStreetMap fetchers once the Wiki and OEIS fetchers are working.

## 4. Dependencies

*   Existing `git-submodules-rs-nix` repository (via `github:meta-introspector`).
*   Existing OEIS-related Rust code (e.g., from `bootstrap`/`lattice-introspector`).
*   `CRQ-059-wikipedia-wikidata-extractor.md` document.
*   `CRQ_INTROSPECTION_SEQUENCES_OEIS_20250903.md` document.
*   Nix flake infrastructure (nixpkgs, flake-utils, flake-parts, naersk).

## 5. Success Criteria

*   The `git-submodules-rs-nix` project and OEIS-related Rust code are successfully integrated and their components are buildable via Nix.
*   Nix-native functions (`fetchWiki`, `fetchOeis`) are exposed through the aggregation flake.
*   These functions can be used by other Nix modules to prefetch and obtain structured data from Wikidata, Wikipedia, and OEIS.
*   The integration adheres to existing project conventions and the new External Dependency Integration Policy.