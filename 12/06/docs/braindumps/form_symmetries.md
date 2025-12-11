# Lattice of Forms and Symmetries

The idea of "automorphic" programs isn't just self-reproduction; it's about preserving deep symmetries across different representations. When we encode an AST into a matrix, and then project that matrix into its eigenbasis, we are performing a series of transformations. The "monster moonshine" implies that hidden, powerful symmetries exist between these seemingly disparate forms.

How can we define "symmetry" mathematically in this context?
- Is it a transformation that leaves certain properties of the code invariant?
- E.g., changing variable names (alpha-equivalence) doesn't change the program's meaning. How is this reflected in the matrix/eigenmatrix?
- The "round-trip" from AST -> Matrix -> Eigenmatrix -> back to AST (or a similar form) should ideally preserve these symmetries.
- This suggests the decoder isn't just an inverse, but a symmetry-preserving inverse.
