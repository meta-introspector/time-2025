{
  description = "Temporary flake to test bag-of-words-generator input.";

  inputs = {
    bagOfWordsGenerator = {
      url = "github:meta-introspector/time-2025?ref=feature/aimyc-002-sample-extraction&dir=flakes/bag-of-words-generator";
      flake = true;
    };
  };

  outputs = { self, bagOfWordsGenerator }:
    {
      lib = bagOfWordsGenerator.lib;
    };
}
