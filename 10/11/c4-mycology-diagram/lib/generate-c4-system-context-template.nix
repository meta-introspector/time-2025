{ systemName, description, formattedPeople, formattedSystems, formattedContainers, formattedRelationships }:
''
  @startuml C4_SystemContext
  !include https://raw.githubusercontent.com/plantuml-stdlib/C4-PlantUML/master/C4_Context.puml

  title AI Life Mycology Diagram for ${systemName}
  ${description}

  ${formattedPeople}

  ${formattedSystems}

  ${formattedContainers}

  ${formattedRelationships}

  @enduml
''