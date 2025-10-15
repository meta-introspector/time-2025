{ pkgs, lib, builtins, llmGeneratorFlake, metaOrchestratorFlake }:
promptString: # The user's prompt, e.g., "a battleship game"
let
  # Construct the detailed LLM prompt for scaffold generation
  llmScaffoldGenerationPrompt = ''
    You are an expert software engineer and Nix flake architect.
    Your task is to generate a complete Nix flake project scaffold based on the following high-level description: "${promptString}".

    The scaffold should include:
    1.  A main `flake.nix` file.
    2.  Necessary source code files (e.g., `src/main.rs` for Rust, `default.nix` for Nix modules).
    3.  A `README.md` file.
    4.  The generated `flake.nix` should be fully functional and include the following outputs:
        *   A `docs.md` target for documentation.
        *   A `packages.${system}.typeAnalysis` target for type analysis, conceptually representing "the universe of universes or UU of unimath".
        *   A `packages.${system}.usesAnalysis` target for dependency analysis, conceptually representing "everything and nothing".
        *   A `packages.${system}.userAnalysis` target for dependent analysis, conceptually representing "everyone and noone".
        *   A `packages.${system}.zkpProof` target for Zero-Knowledge Proofs of input/output validity.

    Provide the output as a tarball or a structured directory that can be directly used as a Nix flake.
    Focus on a minimal but functional scaffold.
  '';

  # Create an LLM call description for this scaffold generation task
  llmCallDescription = (llmGeneratorFlake.lib.${pkgs.system}.llmFunctor) {
    checksum = lib.hashString "sha256" llmScaffoldGenerationPrompt;
    keyObject = llmGeneratorFlake.lib.${pkgs.system}.myKeyObject; # Use dummy key object
    modelRouter = llmGeneratorFlake.lib.${pkgs.system}.myModelRouter; # Use dummy model router
    prompt = llmScaffoldGenerationPrompt;
    expectedOutputFormat = "text"; # Expecting code/files, not just markdown
  };

  # Create an LLM call vector
  llmCallVectorDescription = (llmGeneratorFlake.lib.${pkgs.system}.llmCallVectorFunctor) {
    inherit lib;
    calls = [ llmCallDescription ];
  };

  # Invoke the impure LLM orchestrator to get the LLM tasks for scaffold generation
  # This will output a JSON array of LLM tasks, not the scaffold itself yet.
  # The actual scaffold generation (by a miner) is a subsequent step.
  scaffoldGenerationLLMTasks = pkgs.runCommand "scaffold-generation-llm-tasks" {
    __noChroot = true; # Impure call to orchestrator
    __noSandbox = true;
    buildInputs = [ pkgs.bash pkgs.jq ];
    LLM_CALL_VECTOR_JSON = builtins.toJSON llmCallVectorDescription;
    KEY_OBJECT_JSON = builtins.toJSON llmGeneratorFlake.lib.${pkgs.system}.myKeyObject;
    MODEL_ROUTER_JSON = builtins.toJSON llmGeneratorFlake.lib.${pkgs.system}.myModelRouter;
    FLAKE_CONTENT = ""; # No specific flake content for this prompt, it's generative
    script = pkgs.writeScript "llm-orchestrator-wrapper" ''
      bash ${llmGeneratorFlake.lib.${pkgs.system}.llmOrchestratorScript} "$LLM_CALL_VECTOR_JSON" "$KEY_OBJECT_JSON" "$MODEL_ROUTER_JSON" "$FLAKE_CONTENT" > $out
    '';
  } "$script";

  # Placeholder for the actual scaffold (after a miner executes scaffoldGenerationLLMTasks)
  # For now, this will just be a derivation containing the LLM tasks.
  generatedScaffold = scaffoldGenerationLLMTasks; # This needs to be replaced by the actual scaffold later

  docs.md = pkgs.writeText "dwim-flake-docs.md" ''
# DWIM (Do What I Mean) Flake

## Description

The DWIM flake is a powerful abstraction designed for autonomous project generation. It takes a high-level natural language prompt and, leveraging LLM capabilities, generates a complete Nix flake project scaffold. This scaffold is not just raw code; it's designed to be fully integrated into the project's meta-orchestration framework, including predefined task outputs for documentation, type analysis, usage analysis, user analysis, and Zero-Knowledge Proofs.

## Inputs

-   `promptString`: A string describing the desired project (e.g., "a battleship game", "a Dioxus webapp"). This is the primary input that guides the LLM's generation.
-   `pkgs`, `lib`, `builtins`: Standard Nix library functions.
-   `llmGeneratorFlake`: A reference to the LLM generator flake, used to create and execute LLM tasks for scaffold generation.
-   `metaOrchestratorFlake`: A reference to the meta-orchestrator flake, which will process the generated scaffold and apply further tasks.

## Outputs

-   `output`: A derivation containing a JSON array of LLM tasks. These tasks, when executed by a miner, will generate the project scaffold. This output includes cost and benefit metadata for each task.
-   `bootstrap.scaffold`: A convenience target to trigger the initial LLM query for scaffold generation. Building this target will produce the LLM tasks that, when executed, will create the project scaffold.

## How it Works

1.  **Prompt Interpretation:** The `promptString` is used to construct a detailed LLM prompt.
2.  **LLM Task Generation:** This prompt is then encapsulated into an LLM task using the `llmGeneratorFlake`. This task instructs the LLM to generate a `flake.nix` project scaffold that *already includes* outputs for `docs.md`, `packages.${system}.typeAnalysis`, `packages.${system}.usesAnalysis`, `packages.${system}.userAnalysis`, and `packages.${system}.zkpProof`.
3.  **Miner Execution (External):** The generated LLM task (output by the DWIM flake) is then picked up by a miner. The miner executes this task (making the actual LLM API call) to produce the raw project scaffold.
4.  **Meta-Orchestration (Subsequent Step):** The raw scaffold is then fed into the `metaOrchestratorFlake` for further processing, including documentation generation, type checking, and ZKP proving.

## Usage Example

To generate the initial LLM tasks for a "battleship game" project:

```bash
nix build /path/to/dwim/flake.nix -L --argstr promptString "a battleship game"
# The output will be a JSON file containing the LLM tasks.
# A miner would then execute these tasks.
```

To trigger the initial scaffold generation query:

```bash
nix build /path/to/dwim/flake.nix#bootstrap.scaffold --argstr promptString "a battleship game"
# This will build the LLM tasks for scaffold generation.
# The actual scaffold will be produced when these tasks are executed by a miner.
```
  '';

in
{
  name = "dwim-flake";
  description = "A 'Do What I Mean' flake that generates a project scaffold based on a prompt.";
  # The output is the generated scaffold (or the LLM tasks to generate it)
  output = generatedScaffold;

  bootstrap.scaffold = generatedScaffold;
}
