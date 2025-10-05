{
  pandasModule,
  pkgs,
  lib,
  builtins,
  ...
}:

let
  plotSchemaModule = import ./plot_schema.nix { inherit lib; };
  createPlot = (import ./create_plot.nix { inherit lib; PlotSchema = plotSchemaModule.PlotSchema; }).createPlot;
  renderPlot = (import ./render_plot.nix { inherit lib pkgs builtins; PlotSchema = plotSchemaModule.PlotSchema; }).renderPlot;
  PlotSchema = plotSchemaModule.PlotSchema;
  examplePlot = (import ./example_plot.nix { inherit pandasModule pkgs builtins lib; inherit createPlot renderPlot; }).examplePlot;
in
{
  inherit createPlot renderPlot PlotSchema examplePlot;
}