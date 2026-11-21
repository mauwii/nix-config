{ pkgs, ... }:
{
  # Theme is left at bat's default, which follows the terminal's light/dark mode.
  programs.bat = {
    enable = true;
    extraPackages = with pkgs.bat-extras; [
      batdiff
      batgrep
      batman
      batwatch
    ];
  };

  # Render manpages with bat; MANROFFOPT keeps roff from emitting escapes bat would show raw.
  home.sessionVariables = {
    MANPAGER = "sh -c 'col -bx | bat --language=man --plain'";
    MANROFFOPT = "-c";
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    # bash_path is left at its default: nix-direnv needs a modern bash,
    # macOS' /bin/bash is 3.2
    config.global = {
      load_dotenv = true;
      strict_env = true;
    };
  };

  programs.eza = {
    enable = true;
    icons = "auto";
    git = true;
    extraOptions = [ "--group-directories-first" ];
  };

  # Override the default eza aliases (ls, ll) with the ones from the old dotfiles;
  # la, lt and lla keep the home-manager defaults.
  programs.zsh.shellAliases = {
    ls = "eza --accessed --modified --created";
    l = "ls -a --header";
    ll = "l -lg";
    lll = "ll -@";
    lr = "ls -R";
    llr = "lr -l";
    # bat acts like plain cat when piped, so the alias is safe in pipelines
    cat = "bat --paging=never";
  };
}
