{
  nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
  flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
  gemini-cli.url = "github:meta-introspector/gemini-cli?ref=feature/CRQ-016-nixify-2025-10-06";
  vial.url = "path:./vial-placeholder"; # Placeholder for the actual vial flake
  mycologyContext = { }; # Optional input for mycology framework context
}
