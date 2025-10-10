{ lib, pkgs }:

let
  # Curated list of unique GitHub URLs from grep output
  allUniqueGithubUrls = [
    "github:meta-introspector/synapse-system?dir=nix/flakes/4QZero&ref=feature/base-agent-flake"
    "github:meta-introspector/time-2025/feature/foaf?dir=09/26/synapse-system/nix/flakes/4QZero"
    "github:meta-introspector/time-2025/feature/foaf?dir=09/26/synapse-system/nix/flakes/agent"
    "github:meta-introspector/time-2025/feature/foaf?dir=09/26/synapse-system/nix/flakes/architect"
    "github:meta-introspector/synapse-system?dir=nix/flakes/base-agent&ref=feature/base-agent-flake"
    "github:meta-introspector/time-2025?ref=feature/lattice-30030-homedir&dir=09/27/7-concepts/6-qa-testing/tests/consolidated-impure-gemini-telemetry"
    "github:meta-introspector/flake-utils"
    "github:nix-community/flake-compat/pull/4/head"
    "github:meta-introspector/flake-parts?ref=feature/CRQ-016-nixify"
    "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify"
    "github:numtide/flake-utils"
    "github:meta-introspector/time-2025/feature/foaf?dir=flakes/foaf/context"
    "github:meta-introspector/time-2025/feature/foaf?dir=flakes/foaf/seed-data"
    "github:meta-introspector/time-2025/feature/foaf?dir=09/27/7-concepts/2-gemini-integration/gemini-integration/gemini_api_consumer_flake"
    "github:meta-introspector/time-2025/feature/foaf?dir=09/26/jobs/vendor/nix-task/examples/gemini-caller-flake"
    "github:meta-introspector/gemini-cli?ref=feature/CRQ-016-nixify-2025-10-06"
    "github:meta-introspector/time-2025/feature/foaf?dir=10/02/fetch-github-data"
  ];

  # Convert URLs to flake inputs
  flakeInputs = lib.listToAttrs (lib.map (url: {
    name = lib.strings.sanitizeDerivationName (lib.strings.removePrefix "github:" url);
    value = { inherit url; };
  }) allUniqueGithubUrls);

in
flakeInputs
