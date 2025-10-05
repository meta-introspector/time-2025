{
  pandasModule,
  pkgs,
  lib,
  builtins,
  ...
}:

let
  plotSchemaModule = import ./plot_schema.nix { inherit lib; };
  createPlotModule = import ./create_plot.nix { inherit lib; PlotSchema = plotSchemaModule.PlotSchema; };
  renderPlotModule = import ./render_plot.nix { inherit lib pkgs builtins plotSchemaModule.PlotSchema; };
  examplePlotModule = import ./example_plot.nix { inherit pandasModule createPlotModule.createPlot renderPlotModule.renderPlot pkgs builtins lib; };
in
{
  createPlot = createPlotModule.createPlot;
  renderPlot = renderPlotModule.renderPlot;
  PlotSchema = plotSchemaModule.PlotSchema; # Export the type definition
  examplePlot = examplePlotModule.examplePlot;
}