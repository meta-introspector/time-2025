{ lib, ... }:

{
  generateIdentityMatrix = size:
    lib.genList
      (rowIdx:
        lib.genList
          (colIdx: if rowIdx == colIdx then "1.0" else "0.0")
          size
      )
      size;

  # Helper to convert a list of floats to a list of strings
  floatsToStrings = list: lib.map toString list;

  generateUniformVector = size: value: lib.genList (i: value) size;
}
