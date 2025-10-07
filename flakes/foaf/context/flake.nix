{
  description = "Defines the FOAF context URI.";

  outputs = { self, nixpkgs }: {
    lib = {
      foafContext = "http://xmlns.com/foaf/0.1/";
    };
  };
}
