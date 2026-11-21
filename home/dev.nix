{
  config,
  lib,
  pkgs,
  ...
}:
let
  npmPrefix = "${config.xdg.dataHome}/npm";
in
{
  home.packages = with pkgs; [
    # build tools
    cmake
    ninja
    glslang
    xcodegen

    # linters & git hooks
    gitleaks
    hadolint
    prek # pre-commit replacement, uses uv instead of virtualenv
    shellcheck
    shfmt
    sonarqube-cli

    # kubernetes & infrastructure
    kubernetes-helm
    # minikube ships a kubectl symlink that downloads a binary on first use
    (lib.hiPrio kubectl)
    minikube
    # downloads OpenTofu/Terraform per project version file, signature-checked (tfenv was not)
    tenv

    jq
    nodejs_26
    # global interpreter for ad-hoc scripts; projects use uv
    python3
  ];

  programs.uv.enable = true;

  # tenv defaults to ~/.tenv
  home.sessionVariables.TENV_ROOT = "${config.xdg.dataHome}/tenv";

  # The Nix store is read-only, so `npm install -g` needs a writable prefix
  home.sessionVariables.NPM_CONFIG_PREFIX = npmPrefix;
  home.sessionPath = [ "${npmPrefix}/bin" ];

  # Nothing is declared, so ~/.claude stays untouched. The nixpkgs build has
  # its auto-updater disabled.
  programs.claude-code.enable = true;

  programs.gh = {
    enable = true;
    # also sets gh as git credential helper for github.com
    gitCredentialHelper.enable = true;
    settings = {
      git_protocol = "https";
      clipboard = "enabled";
      aliases.co = "pr checkout";
    };
  };
}
