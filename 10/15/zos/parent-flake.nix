{
  description = "Dummy parent flake for testing recursive generation.";

  outputs = { self, ... }:
    {
      generation = 1;
    };
}
