# CRQ-030: Repository Placement Guidelines

*   **Status:** Proposed
*   **Author:** Gemini
*   **Date:** 2025-09-21

## 1. Problem Statement

The current lack of standardized guidelines for the placement of new and existing repositories, sub-repositories, and experimental projects within the main project structure leads to disorganization, difficulty in locating specific codebases, and hinders efficient collaboration and knowledge management. This "mess" impedes the project's scalability and maintainability.

## 2. Proposed Solution

Establish clear and consistent guidelines for repository placement, guided by the "digital mycology procedure." This will ensure a logical and predictable structure for all code strains (repos, subrepos, subsubrepos), facilitating discovery, integration, and long-term management.

## 3. Scope

*   **In Scope:**
    *   Definition of primary directories for different types of repositories (e.g., external, internal, experimental).
    *   Establishment of naming conventions and hierarchical structures for new repository placements.
    *   Creation of `docs/sops/SOP_Repository_Placement_Guidelines.md`.
*   **Out of Scope:**
    *   Automated enforcement of placement rules (though this SOP will lay the groundwork for future automation).
    *   Migration of all existing "messy" repositories (this would be a separate, subsequent task).

## 4. Implementation Details

### 4.1. Create `docs/sops/SOP_Repository_Placement_Guidelines.md`

This new SOP will detail the specific rules and recommended paths for repository placement. It will include:

*   **Standard Root Directories:**
    *   `vendor/`: For external, third-party repositories (e.g., cloned dependencies, vendored code).
    *   `source/github/meta-introspector/`: For internal, first-party repositories developed under the `meta-introspector` organization.
    *   `source/github/[other_org]/`: For internal projects from other organizations.
*   **Experimental/Random Streams:**
    *   A dedicated location for experimental or "stream of random" projects, such as:
        *   `source/github/meta-introspector/streamofrandom/YYYY/MM/DD/[project_name]/`
        *   This path will be used for temporary, exploratory, or "dank quasi meta meme" projects that are not yet ready for formal integration. The `YYYY/MM/DD` will be the creation date.
*   **Sub-Repository Placement:** Guidelines for nesting repositories (submodules, sub-submodules) within these primary directories.
*   **Digital Mycology Principle:** Emphasize that repository placement should reflect the "digital mycology" procedure – the organic growth and integration of "living strains" of code, ensuring each "dank quasi meta meme" finds its appropriate place in the knowledge ecosystem.

## 5. Expected Outcomes

*   A clear, standardized structure for all project repositories.
*   Improved discoverability and organization of codebases.
*   Reduced "mess" and increased maintainability.
*   Enhanced adherence to the Quality Doctrine and the "digital mycology" philosophy.

## 6. Rollback Plan

To roll back, this CRQ can be marked as "Deprecated" or "Rejected," and the `docs/sops/SOP_Repository_Placement_Guidelines.md` file can be removed.
