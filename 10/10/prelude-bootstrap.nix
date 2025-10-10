{ lib, pkgs }:

{
  # Flake input for synapse-system's 4QZero agent, base-agent-flake branch
  synapse-system-4qzero = {
    url = "github:meta-introspector/synapse-system?dir=nix/flakes/4QZero&ref=feature/base-agent-flake";
  };

  # Flake input for time-2025's 4QZero agent, foaf branch
  time-2025-4qzero = {
    url = "github:meta-introspector/time-2025/feature/foaf?dir=09/26/synapse-system/nix/flakes/4QZero";
  };

  # Flake input for time-2025's agent, foaf branch
  time-2025-agent = {
    url = "github:meta-introspector/time-2025/feature/foaf?dir=09/26/synapse-system/nix/flakes/agent";
  };

  # Flake input for time-2025's architect, foaf branch
  time-2025-architect = {
    url = "github:meta-introspector/time-2025/feature/foaf?dir=09/26/synapse-system/nix/flakes/architect";
  };

  # Flake input for synapse-system's base-agent, base-agent-flake branch
  synapse-system-base-agent = {
    url = "github:meta-introspector/synapse-system?dir=nix/flakes/base-agent&ref=feature/base-agent-flake";
  };

  # Flake input for time-2025's consolidated-impure-gemini-telemetry, lattice-30030-homedir branch
  time-2025-consolidated-telemetry = {
    url = "github:meta-introspector/time-2025?ref=feature/lattice-30030-homedir&dir=09/27/7-concepts/6-qa-testing/tests/consolidated-impure-gemini-telemetry";
  };

  # Flake input for meta-introspector/flake-utils (no specific ref/dir provided in grep output)
  meta-introspector-flake-utils = {
    url = "github:meta-introspector/flake-utils";
  };

  # Flake input for nix-community/flake-compat, pull/4/head
  nix-community-flake-compat = {
    url = "github:nix-community/flake-compat/pull/4/head";
  };

  # Flake input for meta-introspector/flake-parts, CRQ-016-nixify branch
  meta-introspector-flake-parts = {
    url = "github:meta-introspector/flake-parts?ref=feature/CRQ-016-nixify";
  };

  # Flake input for meta-introspector/flake-utils, CRQ-016-nixify branch
  meta-introspector-flake-utils-crq = {
    url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
  };

  # Flake input for numtide/flake-utils (no specific ref/dir provided in grep output)
  numtide-flake-utils = {
    url = "github:numtide/flake-utils";
  };

  # Flake input for time-2025's foaf context, foaf branch
  time-2025-foaf-context = {
    url = "github:meta-introspector/time-2025/feature/foaf?dir=flakes/foaf/context";
  };

  # Flake input for time-2025's foaf seed-data, foaf branch
  time-2025-foaf-seed-data = {
    url = "github:meta-introspector/time-2025/feature/foaf?dir=flakes/foaf/seed-data";
  };

  # Flake input for time-2025's gemini-api-consumer-flake, foaf branch
  time-2025-gemini-api-consumer = {
    url = "github:meta-introspector/time-2025/feature/foaf?dir=09/27/7-concepts/2-gemini-integration/gemini-integration/gemini_api_consumer_flake";
  };

  # Flake input for time-2025's gemini-caller-flake, foaf branch
  time-2025-gemini-caller = {
    url = "github:meta-introspector/time-2025/feature/foaf?dir=09/26/jobs/vendor/nix-task/examples/gemini-caller-flake";
  };

  # Flake input for meta-introspector/gemini-cli, CRQ-016-nixify-2025-10-06 branch
  meta-introspector-gemini-cli = {
    url = "github:meta-introspector/gemini-cli?ref=feature/CRQ-016-nixify-2025-10-06";
  };

  # Flake input for time-2025's fetch-github-data, foaf branch
  time-2025-fetch-github-data = {
    url = "github:meta-introspector/time-2025/feature/foaf?dir=10/02/fetch-github-data";
  };
}
