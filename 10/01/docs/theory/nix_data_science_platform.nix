{ pandasModule
, jupyterModule
, matplotlibModule
, ...
}:

let
  common = import ../../../lib/common-imports.nix { };
  inherit (common) lib;
  inherit (common) pkgs;
  inherit (common) builtins;

  # A function to run a data science workflow defined as a Jupyter notebook in Nix.
  runDataScienceWorkflow =
    { notebookDefinition
    , # A notebook created using jupyterModule.createNotebook
      name ? "data-science-workflow-execution"
    ,
    }:
    pkgs.runCommand name
      {
        inherit notebookDefinition;
        __impure = true; # Workflow execution might involve impure steps (e.g., rendering plots)
        nativeBuildInputs = [ pkgs.jq ]; # For processing JSON outputs
      }
      '''
    echo "Executing Nix-native data science workflow: ${name}..." >&2
    mkdir -p $out

    # Conceptual execution of the notebook
    # In a real scenario, this would involve iterating through notebookDefinition.cells
    # and executing each one, passing outputs as inputs to the next.
    # For now, we'll simulate the execution and plot generation.

    echo "--- Workflow Steps ---" > $out/workflow_log.txt

    # Simulate execution of the example dataAnalysisWorkflow
    # This would involve evaluating the Nix expressions for each cell
    # and potentially rendering plots.

    # Accessing the cells from the notebookDefinition
    CELLS_JSON=$(echo "${builtins.toJSON notebookDefinition.cells}")

    # Iterate through cells and simulate execution
    echo "$CELLS_JSON" | jq -c '.[]' | while read cell_json; do
      CELL_ID=$(echo "$cell_json" | jq -r '.id')
      CELL_TYPE=$(echo "$cell_json" | jq -r '.type')
      CELL_CONTENT=$(echo "$cell_json" | jq -r '.content')
      CELL_OUTPUT=$(echo "$cell_json" | jq -r '.output')

      echo "Processing Cell ID: $CELL_ID (Type: $CELL_TYPE)" >> $out/workflow_log.txt
      echo "  Content: $CELL_CONTENT" >> $out/workflow_log.txt
      echo "  Output: $CELL_OUTPUT" >> $out/workflow_log.txt

      # If the cell output is a plot definition, conceptually render it
      if [ "$CELL_ID" = "final_result" ]; then # Assuming final_result cell might lead to a plot
        echo "  Conceptual: Attempting to render a plot from this cell's output..." >> $out/workflow_log.txt
        # In a real scenario, you would call matplotlibModule.renderPlot here
        # For now, we'll just create a dummy plot file.
        echo "Conceptual Plot Content for ${CELL_ID}" > $out/${CELL_ID}_plot.png
        echo "  Plot generated (conceptual) at $out/${CELL_ID}_plot.png" >> $out/workflow_log.txt
      fi

    done

    echo "Workflow execution complete. Log in $out/workflow_log.txt" >&2
  '';

in
{
  inherit runDataScienceWorkflow;
  # Export the example workflow from jupyter.nix
  exampleDataAnalysisWorkflow = jupyterModule.dataAnalysisWorkflow;
}
