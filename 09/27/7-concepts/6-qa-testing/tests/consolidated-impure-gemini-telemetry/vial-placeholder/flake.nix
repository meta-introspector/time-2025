
{
  description = "A placeholder vial flake for Gemini prompts.";

  outputs = { self, ... } @ args:
    {
      lib.getPrompt = { pkgs }: "Default prompt from vial-placeholder flake.";
    };
}
