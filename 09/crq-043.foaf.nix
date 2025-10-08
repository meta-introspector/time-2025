{ lib, pkgs, ... }:

let
  crqId = "CRQ-043";
  title = "Abstract All Nix Code";
  description = ''
    This CRQ mandates the abstraction of all Nix code within the project. This means:

    1.  **No Raw Nix Expressions**: Direct, un-abstracted Nix expressions should be minimized or eliminated.
    2.  **Modularization**: All Nix logic should be encapsulated within well-defined functions, modules, or libraries.
    3.  **Parameterization**: Code should be parameterized to enhance reusability and configurability.
    4.  **Clear Interfaces**: Each Nix abstraction should expose a clear and stable interface.
    5.  **Testability**: Abstracted code should be easily testable, promoting robust and verifiable implementations.

    The goal is to improve maintainability, readability, and to facilitate formal verification efforts.
  '';
in
{
  ${crqId} = {
    inherit title description;
    id = crqId;
    status = "proposed";
    priority = "high";
    tags = [ "Nix" "abstraction" "modularization" "maintainability" "formal-verification" ];
  };
}
