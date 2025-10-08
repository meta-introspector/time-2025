{
  description = "Vial for summarizing Markdown files.";

  outputs = { self, ... } @ args:
    {
      lib.getPrompt = { pkgs, fileContent }:
        ''
          Summarize the following Markdown content, highlighting its main points and purpose.

          Markdown Content:
          ```markdown
          ${fileContent}
          ```
        '';
    };
}
