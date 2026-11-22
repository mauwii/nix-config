{ config, ... }:
let
  npmPrefix = "${config.xdg.dataHome}/npm";
in
{
  # tenv defaults to ~/.tenv
  home.sessionVariables.TENV_ROOT = "${config.xdg.dataHome}/tenv";

  # keeps `npm install -g` out of the prefix that Homebrew manages
  home.sessionVariables.NPM_CONFIG_PREFIX = npmPrefix;
  home.sessionPath = [ "${npmPrefix}/bin" ];

  programs.gh = {
    enable = true;
    # also sets gh as git credential helper for github.com
    gitCredentialHelper.enable = true;
    settings = {
      git_protocol = "https";
      clipboard = "enabled";
      aliases.co = "pr checkout";
    };
  };
}
