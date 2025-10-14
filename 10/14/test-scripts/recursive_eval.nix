let
  naerskFlake = builtins.getFlake "github:meta-introspector/naersk?ref=feature/CRQ-016-nixify";

  # Recursive function to list all attributes
  listAttrsRecursive = name: value:
    if builtins.isAttrs value then
      builtins.concatMap (attrName: listAttrsRecursive (name + "." + attrName) (value.${attrName})) (builtins.attrNames value)
    else
      [ name ];

in
builtins.toJSON (listAttrsRecursive "naersk" naerskFlake.lib)
