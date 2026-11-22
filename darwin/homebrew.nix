{ lib, username, ... }:
{
  nix-homebrew = {
    enable = true;
    user = username;
    # brew shellenv would put Homebrew in front of Nix in the PATH
    enableBashIntegration = false;
    enableFishIntegration = false;
    enableZshIntegration = false;
    extraEnv = {
      HOMEBREW_NO_ANALYTICS = "1";
      # homebrew.caskArgs.require_sha would only apply to installs, not to upgrades
      HOMEBREW_CASK_OPTS = "--require-sha";
    };
  };

  # after the Nix profiles, but before the older tools of macOS
  environment.systemPath = lib.mkOrder 1100 [
    "/opt/homebrew/bin"
    # `python` and `pip` without version, the formula only links `python3`
    "/opt/homebrew/opt/python@3.15/libexec/bin"
  ];

  homebrew = {
    enable = true;
    # never "uninstall" or "zap", they can delete App Store apps
    onActivation.cleanup = "check";

    # for all Macs, private ones are in profiles/private.nix
    brews = [
      # build tools
      "cmake"
      "glslang"
      "ninja"
      "xcodegen"

      # linters & git hooks
      "gitleaks"
      "hadolint"
      "nixfmt"
      "prek" # pre-commit replacement, uses uv instead of virtualenv
      "shellcheck"
      "shfmt"

      # kubernetes & infrastructure
      "helm"
      "kubernetes-cli"
      "minikube"
      # downloads OpenTofu/Terraform per project version file, signature-checked (tfenv was not)
      "tenv"

      # docker client, the engine runs in colima (home/docker.nix)
      "docker"
      "docker-buildx"
      "docker-compose"
      "docker-credential-helper"

      "eza"
      "git"
      "jq"

      "node"
      # runs the language server of SonarLint, see home/editors.nix
      "openjdk@21"
      # global interpreter for ad-hoc scripts; projects use uv
      "python@3.15" # only the newest formula provides `python3`
      "uv"
    ];

    casks = [
      "claude"
      "claude-code@latest"
      # used by iTerm2, VSCodium and the starship symbols
      "font-fira-code-nerd-font"
      "iterm2"
      "sonarqube-cli"
      "vlc"
      "vscodium"
    ];
  };
}
