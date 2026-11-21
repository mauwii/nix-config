{
  self,
  pkgs,
  username,
  ...
}:
{
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  # Determinate Nix manages the Nix daemon and /etc/nix/nix.conf itself,
  # so nix-darwin must not touch them. Custom Nix settings belong in
  # /etc/nix/nix.custom.conf.
  nix.enable = false;

  users.users.${username}.home = "/Users/${username}";

  # User that system.defaults.* apply to
  system.primaryUser = username;

  # System-wide packages (end up in /run/current-system/sw/bin).
  # Prefer per-user packages in home/default.nix (home.packages).
  environment.systemPackages = [ ];

  # Writes /etc/zshrc & /etc/zshenv so Nix paths are available in every zsh
  programs.zsh.enable = true;
  # home-manager runs compinit (with a cached dump), don't run it twice
  programs.zsh.enableCompletion = false;

  system.configurationRevision = self.rev or self.dirtyRev or null;

  # Do not change without reading the nix-darwin release notes
  system.stateVersion = 6;
}
