# Only for private Macs, everything in darwin/ and home/ also lands on a work Mac
{ username, ... }:
{
  homebrew.casks = [
    "brave-browser"
    "calibre"
    "lm-studio"
    "signal"
  ];

  homebrew.masApps."Logic Pro" = 634148309;

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
