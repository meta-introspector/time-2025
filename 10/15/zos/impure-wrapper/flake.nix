{
  description = "ZOS Impure Wrapper Flake: A specification and executor for deferred, ZKP-provable impure calls.";

  inputs = {
    nixpkgs.url = "github:meta-introspector/nixpkgs?ref=feature/CRQ-016-nixify";
    flake-utils.url = "github:meta-introspector/flake-utils?ref=feature/CRQ-016-nixify";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;

        # This flake is designed to be called as a function, taking a 'callSpec' as an argument.
        # Example usage: impureWrapperFlake.packages.${system}.default { callSpec = { ... }; }
        # Or, more directly, impureWrapperFlake.lib.${system}.createImpureCall { callSpec = { ... }; }
        createImpureCall = { callSpec }:
          let
            # Default values for callSpec
            defaultCallSpec = {
              name = "unnamed-impure-call";
              description = "A deferred impure call.";
              command = "echo 'No command specified.'";
              inputs = {}; # Attribute set of input derivations/paths
              outputs = {}; # Attribute set of expected output types/paths
              typeSignature = "Any -> Any"; # Placeholder for formal type signature
              impureFlags = { __noChroot = true; __noSandbox = true; };
              buildInputs = [ pkgs.bash ];
            };
            mergedCallSpec = defaultCallSpec // callSpec;

            executor = pkgs.runCommand mergedCallSpec.name (
              mergedCallSpec.impureFlags // {
                inherit (mergedCallSpec) buildInputs;
                commandToExecute = mergedCallSpec.command;
              } // mergedCallSpec.inputs # Merge inputs into the derivation attributes
            ) ''
              echo "Executing deferred impure call: ${mergedCallSpec.name}" >&2
              echo "Description: ${mergedCallSpec.description}" >&2
              echo "Command: ${mergedCallSpec.command}" >&2
              echo "Inputs: ${builtins.toJSON mergedCallSpec.inputs}" >&2
              echo "Expected Outputs: ${builtins.toJSON mergedCallSpec.outputs}" >&2
              
              bash -c "$commandToExecute" > "$out/output.log" 2>&1 || true # Allow command to fail for now

              echo "Impure call executed. Output in $out/output.log"
              echo "Status: executed" > "$out/status.json"
            '';

            zkpProver = pkgs.runCommand "${mergedCallSpec.name}-zkp-prover" {
              inherit executor spec; # Depend on the executor and spec directly
              # Add ZKP tools here
            } ''
              echo "Generating ZKP for ${mergedCallSpec.name}..." > $out
              echo "Proof generated (placeholder)." >> $out
            '';

            zkpVerifier = pkgs.runCommand "${mergedCallSpec.name}-zkp-verifier" {
              inherit zkpProver; # Depend on the prover
              # Add ZKP verification tools here
            } ''
              echo "Verifying ZKP for ${mergedCallSpec.name}..." > $out
              echo "Proof verified (placeholder)." >> $out
            '';
          in
          {
            spec = mergedCallSpec;
            inherit executor zkpProver zkpVerifier;
          };
      in
      {
        # Expose the createImpureCall function in the lib
        lib.createImpureCall = createImpureCall;

        # Example of how to use it (for testing)
        packages.exampleImpureCall = createImpureCall {
          callSpec = {
            name = "fetch-google-homepage";
            description = "Fetches the Google homepage.";
            command = "curl -s https://www.google.com > $out/google.html";
            typeSignature = "URL -> HTML";
            outputs = { html = "Path"; };
            buildInputs = [ pkgs.curl ];
          };
        }.executor; # Build the executor directly for the example
      }
    );
}
