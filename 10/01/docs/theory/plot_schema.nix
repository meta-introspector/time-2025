{ lib }:

{
  # Represents a conceptual plot in Nix.
  PlotSchema = {
    type = "line"; # e.g., "line", "bar", "scatter", "histogram"
    data = null; # The DataFrame or list of data to plot
    x = null; # Column name for x-axis
    y = null; # Column name for y-axis (or list of column names)
    title = null; # Plot title
    xlabel = null; # X-axis label
    ylabel = null; # Y-axis label
    # ... other plotting parameters (colors, markers, legend, etc.)
  };
}
