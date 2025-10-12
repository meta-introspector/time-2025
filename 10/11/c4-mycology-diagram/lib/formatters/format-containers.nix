{ lib, ... }:

{
  formatContainers = containers:
    lib.concatStringsSep "\n" (
      lib.map (c: "Container(${c.id}, \"${c.name}\", \"${c.technology}\", \"${c.description}\")") containers
    );
}