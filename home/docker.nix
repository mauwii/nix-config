{ pkgs, ... }:
{
  # programs.docker-cli only writes config.json, it does not install the client
  home.packages = [ pkgs.docker-client ];

  programs.docker-cli.enable = true;

  # Default profile runs as a launchd agent and becomes the active docker context
  services.colima.enable = true;
  # colima ignores COLIMA_HOME until the directory exists and then creates ~/.colima
  services.colima.colimaHomeDir = ".colima";
}
