{ lib, pkgs, flakeSource, inputFlakes, processFlakes, outputFlakes }:

pkgs.lib.concatStringsSep "\n" [
  "{"
  "  description = \"Derived LLM Task Flake (Partial Application)\";"
  "  inputs = {"
  "    nixpkgs.url = \"${flakeSource}\";"
  (pkgs.lib.concatStringsSep "\n" (pkgs.lib.map (f: "    input-${lib.strings.sanitizeDerivationName f}.url = \"${f}\";") inputFlakes))
  (pkgs.lib.concatStringsSep "\n" (pkgs.lib.map (f: "    process-${lib.strings.sanitizeDerivationName f}.url = \"${f}\";") processFlakes))
  (pkgs.lib.concatStringsSep "\n" (pkgs.lib.map (f: "    output-${lib.strings.sanitizeDerivationName f}.url = \"${f}\";") outputFlakes))
  "  };"
  "  outputs = inputs@{ self, nixpkgs, ... }:"
  "    let"
  "      pkgs = import nixpkgs { system = \"x86_64-linux\"; };"
  "      # Placeholder for parameters/holes to be filled"
  "      taskParameters = { /* ... */ };"
  "    in"
  "    {"
  "      defaultPackage.x86_64-linux = pkgs.runCommand \"derived-llm-task\" {} \"\n"
  "        echo \"Building derived LLM task (partial application)...\" > \"$out\"\n"
  "        echo \"This derived flake represents a partial application with holes.\" >> \"$out\"\n"
  "        echo \"Input Patterns: ${pkgs.lib.concatStringsSep ", " inputFlakes}\" >> \"$out\"\n"
  "        echo \"Process Patterns: ${pkgs.lib.concatStringsSep ", " processFlakes}\" >> \"$out\"\n"
  "        echo \"Outputs: ${pkgs.lib.concatStringsSep ", " outputFlakes}\" >> \"$out\"\n"
  "        echo \"To fully instantiate, parameters like taskParameters would be applied.\" >> \"$out\"\n"
  "        # Example of how an input pattern might be used (conceptual):"
  "        # ${inputs.input-llm-inputs.defaultPackage.x86_64-linux.fillHoles taskParameters}"
  "        # Placeholder for actual LLM task logic using instantiated inputs, processes, and outputs\n"
  "      \";"
  "    };"
  "}"
]
