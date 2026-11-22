_: {
  programs.git = {
    enable = true;
    # comes from Homebrew, security fixes take weeks to reach nixpkgs-unstable
    package = null;
    # from Nix, so the filter calls it by store path: GUI apps lack /opt/homebrew/bin
    lfs.enable = true;

    signing = {
      format = "ssh";
      key = "~/.ssh/id_ed25519.pub";
      signByDefault = true;
      # lets `git log --show-signature` verify my own commits locally
      allowedSigners = ''
        40327258+mauwii@users.noreply.github.com namespaces="git" ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMMXJmOvvKP9MBRSTFYUPRtedKXPb5hHz7ydlseI9cxF
      '';
    };

    settings = {
      user = {
        name = "Matthias Wild";
        # no guessed email: without a matching include below git refuses to commit
        useConfigOnly = true;
      };
      init.defaultBranch = "main";
      commit.verbose = true;
      branch.sort = "-committerdate";
      fetch.prune = true;
      pull.rebase = true;
      push = {
        default = "current";
        autoSetupRemote = true;
      };
      rebase = {
        autoStash = true;
        autosquash = true;
      };
      rerere.enabled = true;

      merge = {
        tool = "vscodium";
        autostash = true;
        log = true;
        conflictStyle = "zdiff3";
      };
      mergetool = {
        keepBackup = false;
        vscodium.cmd = ''codium --wait "$MERGED"'';
      };

      diff = {
        tool = "vscodium";
        renames = "copies";
        algorithm = "histogram";
      };
      difftool = {
        prompt = false;
        vscodium.cmd = ''codium --wait --diff "$LOCAL" "$REMOTE"'';
      };
    };

    # Only files that come from me or my machine belong here. Anything a
    # project produces (build output, virtualenvs, caches, ...) goes into its
    # .gitignore, otherwise nobody notices when it is missing there.
    ignores = [
      # macOS
      ".DS_Store"
      "._*"
      ".Spotlight-V100"
      ".Trashes"

      # Windows
      "Desktop.ini"
      "Thumbs.db"

      # secrets, better ignored twice than committed once
      # (.envrc is not ignored: it holds `use flake` and belongs to the project)
      ".env"
      ".secrets"

      # tools I use which others might not (jfrog, snyk, act)
      ".jfrog_vscode"
      ".dccache"
      "**/.act"
      ".actrc"

      # files I only want on my mac
      "*.mac.local*"
    ];

    includes =
      # the GitHub email follows the remote, so it stays out of company repos
      map
        (url: {
          condition = "hasconfig:remote.*.url:${url}";
          path = ./github.gitconfig;
        })
        [
          "git@github.com:*/**"
          "https://github.com/**"
          "ssh://git@github.com/**"
        ]
      ++ [
        # Machine-local, untracked settings (e.g. work identities via includeIf);
        # git silently skips the include if the file does not exist.
        { path = "~/.local/.gitconfig"; }
      ];
  };
}
