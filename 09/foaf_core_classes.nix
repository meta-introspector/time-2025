{ lib, foaf, mkClass }:

{
  foafClasses = [
    (mkClass { id = "${foaf}Agent"; label = "Agent"; comment = "An agent (e.g. person, group, software or machine)."; })
    (mkClass { id = "${foaf}Project"; label = "Project"; comment = "A project (a collective thing which may be run by one or more agents)."; })
  ];
}