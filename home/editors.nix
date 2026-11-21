{ pkgs, ... }:
{
  programs.neovim.enable = true;

  programs.vscodium = {
    enable = true;

    profiles.default = {
      # anthropic.claude-code stays UI-managed: it releases faster than nixpkgs.
      extensions = with pkgs.vscode-extensions; [
        charliermarsh.ruff
        davidanson.vscode-markdownlint
        detachhead.basedpyright
        editorconfig.editorconfig
        github.vscode-github-actions
        jnoortheen.nix-ide
        mads-hartmann.bash-ide-vscode
        mkhl.shfmt
        ms-azuretools.vscode-containers
        ms-kubernetes-tools.vscode-kubernetes-tools
        ms-python.debugpy
        ms-python.mypy-type-checker
        ms-python.python
        redhat.vscode-xml
        # required by vscode-kubernetes-tools for manifest validation
        redhat.vscode-yaml
        # Cline: coding agent for local LLMs served by LM Studio
        saoudrizwan.claude-dev
        sonarsource.sonarlint-vscode
        streetsidesoftware.code-spell-checker
        streetsidesoftware.code-spell-checker-german
        tamasfe.even-better-toml
        vadimcn.vscode-lldb
      ];

      # Updates come with `nix flake update` (sets "update.mode" = "none")
      enableUpdateCheck = false;

      # settings.json stays a regular file: changes made in the UI are kept,
      # the settings below are merged on top of it on every switch.
      mutableUserSettings = true;

      userSettings = {
        "terminal.integrated.fontFamily" = "FiraCode Nerd Font Mono";

        # the universal sonarlint VSIX bundles no JRE
        "sonarlint.ls.javaHome" = pkgs.jre_headless.home;

        # open Markdown in the preview, but keep the text diff in diff views
        "workbench.editorAssociations" = {
          "*.md" = "vscode.markdown.preview.editor";
        };
        "workbench.diffEditorAssociations" = {
          "*.md" = "default";
        };
      };
    };
  };
}
