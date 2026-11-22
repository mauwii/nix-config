_: {
  # programs.docker-cli only writes config.json, the client comes from Homebrew
  programs.docker-cli.enable = true;
  programs.docker-cli.settings = {
    # config.json is a read-only store link, so `docker login` keeps secrets in the keychain
    credsStore = "osxkeychain";
    # the docker formula bundles neither compose nor buildx
    cliPluginsExtraDirs = [ "/opt/homebrew/lib/docker/cli-plugins" ];
  };

  # Default profile runs as a launchd agent and becomes the active docker context
  services.colima.enable = true;
  # colima ignores COLIMA_HOME until the directory exists and then creates ~/.colima
  services.colima.colimaHomeDir = ".colima";
}
