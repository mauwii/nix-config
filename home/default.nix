{
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./apps.nix
    ./cli.nix
    ./dev.nix
    ./docker.nix
    ./editors.nix
    ./git.nix
    ./starship.nix
    ./zsh.nix
  ];

  # home.username and home.homeDirectory come from users.users in the darwin config

  # Use ~/.config, ~/.cache, ~/.local/state, ... and tell tools about them
  xdg.enable = true;

  home.packages = with pkgs; [
    # used by iTerm2, VSCodium and the starship symbols
    nerd-fonts.fira-code
    # e-book serif for the VSCodium chat, close to Bookerly (not in nixpkgs)
    literata
  ];

  home.sessionPath = [ "$HOME/.local/bin" ];

  home.sessionVariables = {
    CLICOLOR = "1";
    # git only sets its own LESS=FRX when LESS is unset, so keep the quit-if-one-screen
    LESS = "--quit-if-one-screen --RAW-CONTROL-CHARS";
    LESSHISTFILE = "${config.xdg.stateHome}/lesshst";
  };

  programs.home-manager.enable = true;

  # Do not change without reading the home-manager release notes
  home.stateVersion = "26.05";
}
