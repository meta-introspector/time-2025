{ lib, ... }:

let
  vibeDimensions = [
    "duality" # 2
    "structure" # 3
    "pattern" # 5
    "insight" # 7
    "transformation" # 11
    "challenge" # 13
    "communication" # 17
    "manifestation" # 19
  ];

  concepts = [
    "list" # 2
    "ifThenElse" # 3
    "int" # 5
    "attrset" # 7
    "lambda" # 11
    "letIn" # 13
    "string" # 17
    "unsupported" # 19
  ];

in
{
  inherit vibeDimensions concepts;
}
