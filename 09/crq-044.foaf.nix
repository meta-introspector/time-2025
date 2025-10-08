{ lib, pkgs, ... }:

let
  crqId = "CRQ-044";
  title = "Single Instance Function Wrapping";
  description = ''
    This CRQ establishes a strict policy that every function or significant code block
    within the system must be defined only once and, if it represents a core system
    capability or external interaction, must be wrapped by a project-defined function.

    1.  **Uniqueness**: No two functions or code blocks should perform the exact same logic.
        Redundancy must be eliminated through abstraction and reuse.
    2.  **Encapsulation**: Core functionalities, especially those interacting with external
        systems (e.g., API calls, file system operations, Nix builtins with side-effects),
        must be encapsulated within project-specific wrapper functions.
    3.  **Controlled Access**: Direct calls to external libraries or raw system calls should
        be minimized and routed through these wrapper functions to ensure consistent
        behavior, logging, and adherence to security policies.
    4.  **Auditability**: Wrapping functions will provide a single point of control and
        auditing for critical operations, enhancing system transparency and verifiability.
    5.  **Testability**: Encapsulated functions are easier to mock and test, improving the
        overall test coverage and reliability of the system.

    This CRQ aims to enforce a highly modular, auditable, and maintainable codebase.
  '';
in
{
  ${crqId} = {
    inherit title description;
    id = crqId;
    status = "proposed";
    priority = "high";
    tags = [ "Nix" "function-design" "modularity" "code-reuse" "auditability" ];
  };
}
