{ lib, ... }:

let
  tiktokLevels = [
    "n00b"
    "pro"
    "hacker"
  ];

  tiktokOutputPath = "generated/tiktok";
  tiktokScriptExtension = ".md";
  tiktokChallengePrefix = "OEIS Challenge #";
  tiktokChallengeFile = "challenge.txt";
  tiktokScriptFile = "script.txt";
  defaultOeisNumber = "0"; # Placeholder, will be replaced by MiniZinc output

  generateTiktokPrompt = concept: oeisNumber:
    "Generate a TikTok script (${lib.concatStringsSep ", " tiktokLevels} levels) for the '${concept}' concept, including challenge #${oeisNumber} from a virtual OEIS sequence. Focus on explaining the concept in an engaging way for each level.";

in
{
  inherit tiktokLevels tiktokOutputPath tiktokScriptExtension tiktokChallengePrefix tiktokChallengeFile tiktokScriptFile defaultOeisNumber generateTiktokPrompt;
}
