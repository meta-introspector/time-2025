{
  description = "Vial for analyzing Rust files.";

  outputs = { self, ... } @ args:
    {
      lib.getPrompt = { pkgs, fileContent }:
        ''
          Analyze the following Rust code. Identify its purpose, key functions, data structures, and any potential areas for improvement, bugs, or security vulnerabilities.

          Rust Code:
          ```rust
          ${fileContent}
          ```
        '';
    };
}
