{ pkgs, ... }:
{
  # GUI apps end up in ~/Applications/Home Manager Apps. They must not update
  # themselves, updates come with `nix flake update`.
  home.packages = with pkgs; [
    iterm2
    lmstudio
    signal-desktop
  ];

  targets.darwin.defaults."com.googlecode.iterm2" = {
    SUEnableAutomaticChecks = false;
  };
}
