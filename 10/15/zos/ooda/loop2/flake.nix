{
  description = "OODA Loop 2: Executing ZOS task chain";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";

    loop1 = {
      url = "github:meta-introspector/time-2025?ref=feature/lattice-30030-homedir&dir=10/15/zos";
      flake = true;
    };

    observeFlake = { url = "github:meta-introspector/time-2025?ref=feature/lattice-30030-homedir&dir=10/15/zos/tasks/observe"; flake = true; };
    orientFlake = { url = "github:meta-introspector/time-2025?ref=feature/lattice-30030-homedir&dir=10/15/zos/tasks/orient"; flake = true; };
    decideFlake = { url = "github:meta-introspector/time-2025?ref=feature/lattice-30030-homedir&dir=10/15/zos/tasks/decide"; flake = true; };
    actFlake = { url = "github:meta-introspector/time-2025?ref=f3ba06c5951372adcc82192c024bfa7002321c22&dir=10/15/zos/tasks/act"; flake = true; };
    dwimFlake = { url = "github:meta-introspector/time-2025?ref=e25f3a97b23a34f7e89174affbbe9cf1d5930a19&dir=10/15/dwim"; flake = true; };
  };

  outputs = { self, nixpkgs, flake-utils, loop1, observeFlake, orientFlake, decideFlake, actFlake, dwimFlake }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          loop1-output = loop1.packages.${system}.default;

          # Execute the tasks in a sequential chain, passing the output of one
          # as the input to the next. This assumes each task flake's default
          # package is a function that accepts its inputs as arguments.

          observe-result = (observeFlake.packages.${system}.default) {
            # Input for observe is the output of loop1
            zos = loop1-output;
          };

          orient-result = (orientFlake.packages.${system}.default) {
            # Input for orient is the output of observe
            observe = observe-result;
          };

          decide-result = (decideFlake.packages.${system}.default) {
            # Input for decide is the output of orient
            orient = orient-result;
          };

          act-result = (actFlake.packages.${system}.default) {
            # Input for act is the output of decide, passed as actionPlan
            actionPlan = decide-result;
            dwimFlake = dwimFlake;
          };

        in
        {
          packages = {
            # The final result of the loop2 is the output of the 'act' task
            default = act-result;
          };
        });
}
