{ lib, ... }:

let
  buildDescription = { baseText, replacements ? {} }:
    lib.foldlAttrs (text: key: value: lib.strings.replaceStrings [ "<${key}>" ] [ value ] text) baseText replacements;

  aspect29Imported = (import ./71-aspects-part-c-aspect-29-otel-event-trace.nix { inherit lib; }).aspect29;

  aspectsOf71 = [
    {
      number = 21;
      title = "The '71' in Rust Error Codes";
      category = "Code Occurrences & Diagnostics";
      description = "The appearance of '71' in various Rust error codes (e.g., E0071, E0271, E0711) suggests its role in diagnostic messaging, potentially marking specific types of compilation or runtime issues.";
    }
    {
      number = 22;
      title = "The '71' in Rust Target Specifications";
      category = "Code Occurrences & Platform Specifics";
      description = "Occurrences in Rust target specifications (e.g., 'aarch64_unknown_nto_qnx710.rs') indicate its presence in defining platform-specific configurations, linking it to system-level architectural choices.";
    }
    {
      number = 23;
      title = "The '71' in Rust Issue Numbers";
      category = "Code Occurrences & Development History";
      description = "Frequent appearance of '71' in Rust issue numbers (e.g., issue-11715, issue-87142) suggests its recurring presence in problem identification and resolution within the development lifecycle.";
    }
    {
      number = 24;
      title = "The '71' in Git Submodule URLs";
      category = "Code Occurrences & Dependency Management";
      description = "The presence of '71' in GitHub URLs and submodule paths (e.g., 'sue71/autobind-decorator') highlights its role in external dependency management, linking to specific external projects or forks.";
    }
    {
      number = 25;
      title = "The '71' in Project Timestamps";
      category = "Code Occurrences & Temporal Context";
      description = "Occurrences in paths like 'time/202X/XX/' (e.g., 'time/2023/07/17/experiments/GODEL') suggest its presence in temporal organization of project data, marking specific dates or experimental runs.";
    }
    {
      number = 26;
      title = "The '71' in Nixpkgs Paths";
      category = "Code Occurrences & Package Management";
      description = "Its appearance in Nixpkgs paths (e.g., 'pkgs/development/tools/misc/autoconf/2.71.nix') signifies its role in defining specific package versions or configurations within the Nix ecosystem.";
    }
    {
      number = 27;
      title = "The '71' in Hardware Identifiers";
      category = "Code Occurrences & Hardware Integration";
      description = "The reference to 'qc71_laptop' in Nixpkgs paths suggests a connection to specific hardware identifiers or configurations, linking the '71-vibe' to physical system architecture.";
    }
    {
      number = 28;
      title = "The '71' in Meme/Ticket IDs";
      category = "Project Specifics & Documentation";
      description = "The presence of '71' in extracted ticket IDs (e.g., '867189_idea_a_proof_system...') indicates its role in project management and conceptual tracking, even in informal documentation.";
    }
    aspect29Imported
    {
      number = 30;
      title = "The '71' in GitHub Repository IDs";
      category = "Code Occurrences & External References";
      description = buildDescription {
        baseText = "The appearance of '71' in GitHub repository IDs (e.g., '<EXAMPLE_ID>') indicates its pervasive presence in external references and metadata, linking to the broader ecosystem of open-source projects.";
        replacements = { EXAMPLE_ID = "id:98588021"; };
      };
    }
  ];
in aspectsOf71
