{ pkgs, ... }:
{
  # GUI apps end up in ~/Applications/Home Manager Apps. They must not update
  # themselves, updates come with `nix flake update`.
  home.packages = with pkgs; [
    iterm2
    lmstudio
    signal-desktop
  ];

  # Brave resets its Sparkle update settings on start, so its updater cannot be turned off here
  programs.brave.enable = true;

  targets.darwin.defaults."com.googlecode.iterm2" = {
    SUEnableAutomaticChecks = false;
  };
}
