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

    completionInit = ''
      [[ -d "${cacheDir}" ]] || mkdir -p "${cacheDir}"
      autoload -U compinit && compinit -d "${cacheDir}/zcompdump-$ZSH_VERSION"
    '';

    history = {
      path = "${config.xdg.stateHome}/zsh/history";
      size = 50000;
      save = 50000;
      ignoreAllDups = true;
      extended = true;
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
      # Completion styles, see https://zsh.sourceforge.net/Doc/Release/Completion-System.html

      # Matching
      # _oldlist reuses the list on screen, _ignored is the fallback for ignored-patterns
      zstyle ':completion:*' completer _oldlist _complete _ignored
      # case insensitive, unless uppercase letters are typed
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
      # hidden from completion, unless it is the only match
      zstyle ':completion:*' ignored-patterns '.DS_Store'

      # Cache for slow completers (e.g. package lists), kept in the XDG cache
      zstyle ':completion:*' use-cache true
      zstyle ':completion:*' cache-path "${cacheDir}/zcompcache"

      # Menu and layout
      # pick matches with the arrow keys as soon as there is one
      zstyle ':completion:*:default' menu select=1
      # group matches by type, each group under its description as header
      zstyle ':completion:*' group-name '''
      zstyle ':completion:*:descriptions' format '%B%F{white}--- %d ---%f%b'
      zstyle ':completion:*:messages' format '%F{yellow}%d%f'
      zstyle ':completion:*:warnings' format '%B%F{red}No matches for: %F{white}%d%f%b'
      # one group per man page section instead of one long list
      zstyle ':completion:*:manuals' separate-sections true
      # an empty LS_COLORS uses the default colors
      zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"

      # Order for single commands
      # in $array[<Tab>] offer indexes before parameter names
      zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters
      # keep git's order, so recent commits stay newest first
      zstyle ':completion:*:git-checkout:*' sort false
      # make targets first, variables and files only if no target matches
      zstyle ':completion:*:make::' tag-order targets:

      # zsh-autosuggestions: skip large buffers (async is the default since 0.7)
      ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=200

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
