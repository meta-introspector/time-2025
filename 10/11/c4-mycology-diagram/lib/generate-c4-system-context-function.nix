{ lib, template, formatPeople, formatSystems, formatContainers, formatRelationships }:
{ systemName, description, people, systems, containers, relationships }:
template {
  inherit systemName description;
  formattedPeople = formatPeople people;
  formattedSystems = formatSystems systems;
  formattedContainers = formatContainers containers;
  formattedRelationships = formatRelationships relationships;
}
