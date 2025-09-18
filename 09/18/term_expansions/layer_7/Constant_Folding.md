# Constant Folding

Constant folding is a compiler optimization technique where expressions involving only constant values are evaluated at compile time rather than at runtime. For example, if a program contains `x = 5 + 3;`, constant folding would replace this with `x = 8;` during compilation. This reduces the amount of computation needed at runtime, leading to faster program execution.