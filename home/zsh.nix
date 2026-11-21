{
  config,
  pkgs,
  ...
}:
let
  cacheDir = "${config.xdg.cacheHome}/zsh";
in
{
  home.packages = [ pkgs.zsh-completions ];

  programs.zsh = {
    enable = true;
    # ~/.zshenv only sets ZDOTDIR, everything else lives here
    dotDir = "${config.xdg.configHome}/zsh";

    enableCompletion = true;
    completionInit = ''
      [[ -d "${cacheDir}" ]] || mkdir -p "${cacheDir}"
      autoload -U compinit && compinit -d "${cacheDir}/zcompdump-$ZSH_VERSION"
    '';

    history = {
      path = "${config.xdg.stateHome}/zsh/history";
      size = 50000;
      save = 50000;
      ignoreAllDups = true;
      ignoreSpace = true;
      extended = true;
      share = true;
    };

    autosuggestion = {
      enable = true;
      strategy = [
        "history"
        "completion"
      ];
    };

    plugins = [
      {
        name = "fast-syntax-highlighting";
        src = "${pkgs.zsh-fast-syntax-highlighting}/share/zsh/plugins/fast-syntax-highlighting";
      }
    ];

    shellAliases = {
      # recursively delete .DS_Store files
      cleanup = ''find . -name "*.DS_Store" -type f -ls -delete'';
      # remove broken symlinks
      clsym = "find -L . -name . -o -type d -prune -o -type l -exec rm {} +";
      # recursively remove __pycache__ dirs
      clpy = "find . -name __pycache__ -type d -print0 | xargs -0 /bin/rm -rf";
      # list the PATH separated by new lines
      lspath = ''echo $PATH | tr ":" "\n"'';
      # copy the public SSH key to the clipboard
      pubkey = ''pbcopy < "$HOME/.ssh/id_ed25519.pub"'';
    };

    initContent = ''
      # see https://zsh.sourceforge.net/Doc/Release/Completion-System.html
      zstyle ':completion:*' completer _oldlist _complete _ignored
      zstyle ':completion:*:messages' format '%F{yellow}%d%f'
      zstyle ':completion:*:warnings' format '%B%F{red}No matches for: %F{white}%d%f%b'
      zstyle ':completion:*:descriptions' format '%B%F{white}--- %d ---%f%b'
      zstyle ':completion:*' group-name '''
      zstyle ':completion:*' use-cache true
      zstyle ':completion:*' cache-path "${cacheDir}/zcompcache"
      zstyle ':completion:*' ignored-patterns '.DS_Store'
      # an empty LS_COLORS uses the default colors
      zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"
      zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters
      zstyle ':completion:*:git-checkout:*' sort false
      # case insensitive, unless uppercase letters are typed
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
      zstyle ':completion:*:default' menu select=1
      zstyle ':completion:*:manuals' separate-sections true
      # make targets first, variables and files only if no target matches
      zstyle ':completion:*:make::' tag-order targets:

      # zsh-autosuggestions: skip large buffers (async is the default since 0.7)
      ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20

      # VSCodium for local sessions, neovim over SSH
      if [[ -z $SSH_CONNECTION ]] && (( $+commands[codium] )); then
        export EDITOR="codium --wait"
      else
        export EDITOR=nvim
      fi

      export MAKEFLAGS="-j$(sysctl -n hw.ncpu)"

      # LM Studio CLI (lms); via the array, so `typeset -U path` drops duplicates
      path+=("$HOME/.lmstudio/bin")
    '';
  };
}
