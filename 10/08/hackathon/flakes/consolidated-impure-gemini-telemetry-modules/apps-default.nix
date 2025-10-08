{ pkgs, buildTimeTelemetry }:
{
  type = "app";
  program = "${pkgs.writeShellScript "show-build-telemetry" ''
    # ... (script content) ...
  ''}";
}
