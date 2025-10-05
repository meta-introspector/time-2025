{ lib, schema, mkClass }:

{
  schemaClasses = [
    (mkClass { id = "${schema}Solution"; label = "Solution"; comment = "A proposed solution to a problem."; })
    (mkClass { id = "${schema}Impact"; label = "Impact"; comment = "The impact or justification of a solution."; })
  ];
}
