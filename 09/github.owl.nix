{ pkgs, lib, builtins, mkClass, mkObjectProperty, mkDatatypeProperty, github, foaf, rdfs }:

let
  # GitHub Classes
  githubClasses = [
    (mkClass { id = "${github}Repository"; label = "Repository"; comment = "A GitHub repository."; subClassOf = "${foaf}Project"; })
    (mkClass { id = "${github}User"; label = "User"; comment = "A GitHub user."; subClassOf = "${foaf}Agent"; })
    (mkClass { id = "${github}Commit"; label = "Commit"; comment = "A Git commit."; })
    (mkClass { id = "${github}Issue"; label = "Issue"; comment = "A GitHub issue."; })
    (mkClass { id = "${github}PullRequest"; label = "PullRequest"; comment = "A GitHub pull request."; })
    (mkClass { id = "${github}Event"; label = "Event"; comment = "A GitHub event."; })
  ];

  # GitHub Properties
  githubProperties = [
    (mkObjectProperty { id = "${github}hasOwner"; label = "has owner"; domain = "${github}Repository"; range = "${github}User"; })
    (mkObjectProperty { id = "${github}hasContributor"; label = "has contributor"; domain = "${github}Repository"; range = "${github}User"; })
    (mkObjectProperty { id = "${github}hasCommit"; label = "has commit"; domain = "${github}Repository"; range = "${github}Commit"; })
    (mkObjectProperty { id = "${github}hasIssue"; label = "has issue"; domain = "${github}Repository"; range = "${github}Issue"; })
    (mkObjectProperty { id = "${github}hasPullRequest"; label = "has pull request"; domain = "${github}Repository"; range = "${github}PullRequest"; })
    (mkObjectProperty { id = "${github}hasEvent"; label = "has event"; domain = "${github}Repository"; range = "${github}Event"; })
    (mkDatatypeProperty { id = "${github}commitMessage"; label = "commit message"; domain = "${github}Commit"; range = "${rdfs}Literal"; })
    (mkObjectProperty { id = "${github}commitAuthor"; label = "commit author"; domain = "${github}Commit"; range = "${github}User"; })
    (mkDatatypeProperty { id = "${github}issueTitle"; label = "issue title"; domain = "${github}Issue"; range = "${rdfs}Literal"; })
    (mkDatatypeProperty { id = "${github}issueBody"; label = "issue body"; domain = "${github}Issue"; range = "${rdfs}Literal"; })
    (mkDatatypeProperty { id = "${github}issueState"; label = "issue state"; domain = "${github}Issue"; range = "${rdfs}Literal"; })
    (mkDatatypeProperty { id = "${github}eventTimestamp"; label = "event timestamp"; domain = "${github}Event"; range = "${rdfs}Literal"; })
  ];
in
{
  inherit githubClasses;
  inherit githubProperties;
}
