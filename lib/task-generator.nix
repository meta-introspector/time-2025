{ lib, ... }:

let
  generateTask = file_path: type: {
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

in
moduleTasks ++ testTasks
