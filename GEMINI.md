## Gemini CLI Context

This document provides context for the current task being performed by the Gemini CLI.

**Date:** Wednesday, October 8, 2025
**Operating System:** linux

### Current Working Directory
`/data/data/com.termux.nix/files/home/pick-up-nix2/source/github/meta-introspector/streamofrandom/2025/`

### Project Remote
`https://github.com/meta-introspector/time-2025?ref=feature/foaf`

### Location of CRQ Search
`./flakes/crq-search` (relative to the current working directory)

### Relevant GitHub Remotes
- `https://github.com/meta-introspector/streamofrandom?ref=feature/foaf`
- `https://github.com/meta-introspector/pick-up-nix?ref=feature/CRQ-016-nixify`

### Documentation Updates
- Created `docs/sops/SOP_Running_Nix_Tools.md` which details how to run `statix`, `make`, and CRQ-related Nix tools.
- Created `docs/sops/SOP_Secure_Credential_Handling_in_Nix_Scripts.md` outlining the `sops-nix` workflow for managing credentials in Nix flakes.

### External Dependency Integration Policy

- **Integration Method:** All external dependencies are to be integrated via `github:meta-introspector` URLs.
- **Submodule Usage:** Submodules are *not* to be used for general integration of external dependencies. Their use is strictly reserved for scenarios involving *editing, pushing, and tagging* of those external repositories.
- **Assumption:** It is expected that all necessary external dependencies are already checked in and labeled within the `github:meta-introspector` organization.

### Global Context
For broader context and general policies, please refer to `global_gemini.md`.
