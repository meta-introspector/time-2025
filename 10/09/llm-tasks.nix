{ lib
, pkgs
, mkTask
, flakeSources ? [ "github:meta-introspector/time-2025?ref=feature/lattice-30030-homedir" ]
, inputFlakes ? [ "github:meta-introspector/time-2025?ref=feature/lattice-30030-homedir&dir=10/10/llm-inputs" ]
, processFlakes ? [ "github:meta-introspector/time-2025?ref=feature/lattice-30030-homedir&dir=10/10/llm-processes" ]
, outputFlakes ? [ "github:meta-introspector/time-2025?ref=feature/lattice-30030-homedir&dir=10/10/llm-outputs" ]
}:

import ../10/lib-llm-nix/lib {
  inherit lib pkgs mkTask flakeSources inputFlakes processFlakes outputFlakes;
}
