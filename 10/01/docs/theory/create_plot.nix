{ lib, PlotSchema }:

{
  # Conceptual function to create a plot definition.
  createPlot = { type, data, x, y, title ? null, xlabel ? null, ylabel ? null, ... }:
    PlotSchema // { inherit type data x y title xlabel ylabel; };
}
