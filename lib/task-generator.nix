{ lib, ... }:

let
  primeMappingConfig = import ./prime-mapping-config.nix { inherit lib; };
  functorMatrix = import ./code-generation/functor-matrix.nix { inherit lib; };  generateTask = file_path: type: {
    name = "${type}-${(lib.strings.removeSuffix ".nix" (lib.strings.removePrefix "lib/emoji-encoding/" file_path))}";
    inherit file_path;
    derivation_type = type;
    gemini_prompt = "Create a Nix derivation to ${type} the file ${file_path}.";
  };

  emojiEncodingModules = [
    "lib/emoji-encoding/int.nix"
    "lib/emoji-encoding/string.nix"
    "lib/emoji-encoding/list.nix"
    "lib/emoji-encoding/attrset.nix"
    "lib/emoji-encoding/lambda.nix"
    "lib/emoji-encoding/let-in.nix"
    "lib/emoji-encoding/if-then-else.nix"
  ];

  emojiEncodingTests = [
    "tests/emoji-encoding/int-test.nix"
    "tests/emoji-encoding/string-test.nix"
    "tests/emoji-encoding/list-test.nix"
    "tests/emoji-encoding/attrset-test.nix"
    "tests/emoji-encoding/lambda-test.nix"
    "tests/emoji-encoding/let-in-test.nix"
    "tests/emoji-encoding/if-then-else-test.nix"
  ];

  moduleTasks = lib.map (path: generateTask path "build") emojiEncodingModules;
  testTasks = lib.map (path: generateTask path "test") emojiEncodingTests;

  lean4Tasks = lib.map (concept: {
    name = "lean4-gen-${concept}";
    file_path = "generated/lean4/${concept}.lean";
    derivation_type = "generate-lean4";
    gemini_prompt = "Generate Lean4 code for the '${concept}' concept using the functorMatrix.lean4Generators.${concept} function.";
  }) primeMappingConfig.concepts;

  rustTasks = lib.map (concept: {
    name = "rust-gen-${concept}";
    file_path = "generated/rust/${concept}.rs";
    derivation_type = "generate-rust";
    gemini_prompt = "Generate Rust code for the '${concept}' concept using the functorMatrix.rustGenerators.${concept} function.";
  }) primeMappingConfig.concepts;

in
moduleTasks + testTasks + lean4Tasks + rustTasks
