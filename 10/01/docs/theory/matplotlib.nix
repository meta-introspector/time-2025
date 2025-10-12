{ pandasModule
, pkgs
, lib
, builtins
, ...
}:

let
  plotSchemaModule = import ./plot_schema.nix { inherit lib; };
  inherit ((import ./create_plot.nix { inherit lib; inherit (plotSchemaModule) PlotSchema; })) createPlot;
  inherit ((import ./render_plot.nix { inherit lib pkgs builtins; inherit (plotSchemaModule) PlotSchema; })) renderPlot;
  inherit (plotSchemaModule) PlotSchema;
  inherit ((import ./example_plot.nix { inherit pandasModule pkgs builtins lib; inherit createPlot renderPlot; })) examplePlot;
in
{
  inherit createPlot renderPlot PlotSchema examplePlot;
}
