{
  pandasModule,
  ...
}:

let
  common = import ../../../lib/common-imports.nix {};
  lib = common.lib;
  pkgs = common.pkgs;
  builtins = common.builtins;

  # Represents a conceptual Jupyter Notebook/Workbook in Nix.
  # A workbook is a sequence of cells, where each cell is a Nix expression.
  NotebookSchema = {
    cells = []; # List of cells
  };

  # Represents a single cell in the notebook.
  CellSchema = {
    id = null;      # Unique ID for the cell (string)
    type = "code";    # "code", "markdown", "url", "nix-node"
    content = null; # The Nix expression, Markdown string, URL, or Nix store path
    output = null;  # The result of evaluating/fetching the content (conceptual)
  };

  # Conceptual function to create a Notebook
  createNotebook = { cells }:
    NotebookSchema // { inherit cells; };

  # Conceptual function to resolve a cell's content if it's a URL or Nix node.
  # This would be an impure operation for URLs.
  resolveCellContent = cell:
    if cell.type == "url" then
      # Conceptual: Fetch content from URL (impure)
      pkgs.runCommand "fetch-cell-content-${cell.id}" {
        url = cell.content;
        __impure = true;
        nativeBuildInputs = [ pkgs.curl ];
      } ''
        mkdir -p $out
        curl -L "${cell.content}" > $out/content
      ''
    else if cell.type == "nix-node" then
      # Assume cell.content is already a Nix store path or a flake reference
      cell.content
    else
      cell.content; # Return as is for code/markdown

  # Conceptual function to execute a Notebook
  executeNotebook = notebook:
    let
      # This is highly conceptual. Executing arbitrary Nix expressions in sequence
      # and managing state/outputs between them is complex.
      # It would involve a custom Nix evaluator or a build system that orchestrates derivations.
      executedCells = lib.map (cell: # For each cell in the notebook
        let
          resolvedContent = resolveCellContent cell; # Resolve URL/Nix node
          evaluatedContent =
            if cell.type == "code" then
              # Evaluate the Nix expression (conceptual)
              "// Evaluated result of: ${builtins.toString cell.content}"
            else if cell.type == "url" || cell.type == "nix-node" then
              "// Fetched/Referenced content from: ${resolvedContent}"
            else
              cell.content; # Markdown content is just passed through
        in
        cell // { output = evaluatedContent; } # Add the conceptual output to the cell
      ) notebook.cells;
    in
    createNotebook { cells = executedCells; };

  # Conceptual workflow definition using Pandas-like operations
  dataAnalysisWorkflow = 
    let
      # Sample data
      rawData = pandasModule.createDataFrame {
        columns = [ "id" "name" "age" "city" ];
        data = [
          { id = 1; name = "Alice"; age = 30; city = "New York"; }
          { id = 2; name = "Bob"; age = 24; city = "London"; }
          { id = 3; name = "Charlie"; age = 30; city = "Paris"; }
          { id = 4; name = "David"; age = 35; city = "New York"; }
        ];
      };

      # Cell 1: Filter by age > 25
      filteredData = pandasModule.filterRows rawData (row: row.age > 25);

      # Cell 2: Add a new column "is_ny"
      dataWithNewCol = pandasModule.addColumn filteredData "is_ny" (row: row.city == "New York");

      # Cell 3: Select specific columns
      finalResult = pandasModule.selectColumns dataWithNewCol [ "name" "age" "is_ny" ];
    in
    createNotebook {
      cells = [
        (CellSchema // { id = "raw_data"; type = "code"; content = "rawData"; output = rawData; })
        (CellSchema // { id = "filtered_data"; type = "code"; content = "filteredData"; output = filteredData; })
        (CellSchema // { id = "data_with_new_col"; type = "code"; content = "dataWithNewCol"; output = dataWithNewCol; })
        (CellSchema // { id = "final_result"; type = "code"; content = "finalResult"; output = finalResult; })
        # New conceptual cells referencing external data
        (CellSchema // { id = "external_data_url"; type = "url"; content = "https://example.com/some_data.csv"; output = "// Fetched content from https://example.com/some_data.csv"; })
        (CellSchema // { id = "nix_store_node"; type = "nix-node"; content = pkgs.hello; output = "// Reference to pkgs.hello"; })
      ];
    };

in
{
  createNotebook = createNotebook;
  executeNotebook = executeNotebook;
  dataAnalysisWorkflow = dataAnalysisWorkflow;
  NotebookSchema = NotebookSchema;
  CellSchema = CellSchema;
}
