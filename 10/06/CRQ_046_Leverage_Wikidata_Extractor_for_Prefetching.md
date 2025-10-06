# CRQ-046: Leverage Existing Wikidata Extractor for Structured Prefetching

## 1. Introduction

This Change Request outlines a revised approach to prefetching OWL, Wikidata, and Wikipedia articles in a structured manner. Initial investigations into generic prefetch/fetch Nix flakes (like `nurl`, `nix-universal-prefetch`) revealed that while they can fetch raw URLs, they do not inherently provide the "structured manner" processing required.

Further analysis of the project's existing codebase, specifically `~/nix/index/chunks/wikidata.txt`, has revealed that the project already contains a dedicated Rust-based extractor within the `git-submodules-rs-nix/tools/wikidata` project. This existing solution includes client interaction, parsing capabilities, and a formal CRQ (`CRQ-059`) for its development.

This CRQ proposes to leverage this existing infrastructure rather than developing a new fetcher from scratch, thereby aligning with existing project conventions and accelerating development.

## 2. Goals

*   To efficiently prefetch OWL, Wikidata, and Wikipedia articles.
*   To utilize existing project code and infrastructure for parsing and structuring fetched data.
*   To integrate the existing `git-submodules-rs-nix/tools/wikidata` project into the broader Nix flake ecosystem.
*   To ensure a structured output of fetched data that can be consumed by other Nix modules or project components.

## 3. Revised Plan

The following steps will be undertaken to achieve the goals:

### 3.1. Integrate `git-submodules-rs-nix` as a Submodule

Verify and ensure that the `git-submodules-rs-nix` repository is properly integrated as a Git submodule within the project. This will involve checking the `.gitmodules` file and potentially running `git submodule update --init --recursive` if necessary.

### 3.2. Examine `CRQ-059-wikipedia-wikidata-extractor.md`

Read and analyze the existing `CRQ-059-wikipedia-wikidata-extractor.md` document. This will provide crucial insights into the design, requirements, and intended functionality of the extractor, ensuring that our integration aligns with its original purpose.

### 3.3. Examine `git-submodules-rs-nix/tools/wikidata/flake.nix`

Investigate the `git-submodules-rs-nix/tools/wikidata/` directory for an existing `flake.nix` file.
*   If a `flake.nix` exists, understand its outputs (packages, libraries, apps) and how its functionality can be exposed.
*   If no `flake.nix` exists, determine the best approach to Nixify the Rust project (e.g., using `naersk` or `crane`) to build its components within the Nix ecosystem.

### 3.4. Expose the Extractor Functionality via Aggregation Flake

Once the `git-submodules-rs-nix/tools/wikidata` project's components are accessible via Nix, integrate them into the main aggregation flake (`/data/data/com.termux.nix/files/home/nix/vendor/nix/flake.nix`). This will involve:
*   Adding the `git-submodules-rs-nix` flake as an input to the aggregation flake.
*   Exposing relevant packages, libraries, or functions (e.g., a `fetchWikidataArticle` or `fetchWikipediaArticle` function) from the `git-submodules-rs-nix` project as outputs of the aggregation flake.

## 4. Dependencies

*   Existing `git-submodules-rs-nix` repository.
*   `CRQ-059-wikipedia-wikidata-extractor.md` document.
*   Nix flake infrastructure (nixpkgs, flake-utils, flake-parts).

## 5. Success Criteria

*   The `git-submodules-rs-nix` project is successfully integrated and its components are buildable via Nix.
*   A Nix-native function (e.g., `fetchWikidataArticle`, `fetchWikipediaArticle`) is exposed through the aggregation flake.
*   This function can be used by other Nix modules to prefetch and obtain structured data from Wikidata and Wikipedia.
*   The integration adheres to existing project conventions and best practices.
