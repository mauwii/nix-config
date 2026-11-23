# Only for private Macs, everything in darwin/ and home/ also lands on a work Mac
{ username, ... }:
{
  homebrew.casks = [
    "brave-browser"
    "calibre"
    "lm-studio"
    "signal"
  ];

  homebrew.masApps = {
    # IDs of the installed iWork 14.5; the store lookup no longer lists them
    "Keynote" = 409183694;
    "Logic Pro" = 634148309;
    "Numbers" = 409203825;
    "Pages" = 409201541;
    "Telegram" = 747648890;
    "WireGuard" = 1451685025;
  };

  home-manager.users.${username} =
    { lib, pkgs, ... }:
    {
      programs = {
        # default email, also for repos without a remote
        git.includes = lib.mkBefore [ { path = ../home/github.gitconfig; } ];

        vscodium.profiles.default.extensions = [
          # Cline: coding agent for local LLMs served by LM Studio
          pkgs.vscode-extensions.saoudrizwan.claude-dev
        ];

        zsh.initContent = ''
          # LM Studio CLI (lms); via the array, so `typeset -U path` drops duplicates
          path+=("$HOME/.lmstudio/bin")
        '';
      };
    };
}
