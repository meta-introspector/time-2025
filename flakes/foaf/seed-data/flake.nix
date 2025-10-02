{
  description = "Provides seed FOAF data (agents and projects).";

  outputs = { self, nixpkgs }: {
    lib = {
      # Define some seed FOAF agents (people)
      agentMetaIntrospector = {
        "@id" = "http://github.com/meta-introspector";
        "@type" = "Agent";
        "foaf:name" = "Meta Introspector";
        "foaf:mbox" = "mailto:meta-introspector@example.com";
        "foaf:homepage" = "https://github.com/meta-introspector";
      };

      agentGeminiCLI = {
        "@id" = "http://gemini.google.com/cli";
        "@type" = "Agent";
        "foaf:name" = "Gemini CLI";
        "foaf:homepage" = "https://gemini.google.com/cli";
      };

      # Define some seed FOAF projects
      projectStreamOfRandom = {
        "@id" = "http://github.com/meta-introspector/streamofrandom";
        "@type" = "Project";
        "foaf:name" = "Stream of Random";
        "foaf:homepage" = "https://github.com/meta-introspector/streamofrandom";
        "foaf:maker" = self.lib.agentMetaIntrospector; # Reference within the same flake
      };

      projectNixpkgs = {
        "@id" = "http://github.com/meta-introspector/nixpkgs";
        "@type" = "Project";
        "foaf:name" = "Nixpkgs Fork";
        "foaf:homepage" = "https://github.com/meta-introspector/nixpkgs";
        "foaf:maker" = self.lib.agentMetaIntrospector; # Reference within the same flake
      };

      projectFlakeUtils = {
        "@id" = "http://github.com/meta-introspector/flake-utils";
        "@type" = "Project";
        "foaf:name" = "Flake Utils Fork";
        "foaf:homepage" = "https://github.com/meta-introspector/flake-utils";
        "foaf:maker" = self.lib.agentMetaIntrospector; # Reference within the same flake
      };

      seedGraph = [
        self.lib.agentMetaIntrospector
        self.lib.agentGeminiCLI
        self.lib.projectStreamOfRandom
        self.lib.projectNixpkgs
        self.lib.projectFlakeUtils
      ];
    };
  };
}
