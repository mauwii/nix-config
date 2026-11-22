{ config, pkgs, ... }:
{
  programs.neovim.enable = true;

  programs.vscodium = {
    enable = true;
    package = null; # Homebrew delivers it

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
        sonarsource.sonarlint-vscode
        streetsidesoftware.code-spell-checker
        streetsidesoftware.code-spell-checker-german
        tamasfe.even-better-toml
        vadimcn.vscode-lldb
      ];

      # settings.json stays a regular file: changes made in the UI are kept,
      # the settings below are merged on top of it on every switch.
      mutableUserSettings = true;

      userSettings = {
        "chat.editor.fontFamily" = "FiraCode Nerd Font Mono";
        "editor.fontFamily" = "FiraCode Nerd Font Mono";
        "editor.fontLigatures" = true;
        "editor.fontWeight" = "600";
        "git.autofetch" = true;
        "git.confirmSync" = false;
        # GUI apps do not always get the PATH of the shell
        "git.path" = "/opt/homebrew/bin/git";
        "redhat.telemetry.enabled" = false;
        # the universal sonarlint VSIX bundles no JRE
        "sonarlint.ls.javaHome" = "/opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk/Contents/Home";
        "terminal.integrated.fontFamily" = "FiraCode Nerd Font Mono";
        "terminal.integrated.fontSize" = 11;
        "terminal.integrated.fontWeight" = "600";
        # explicit, settings.json would keep an older "none"
        "update.mode" = "default";
        # minikube updates come from Homebrew; the extension's "Install" would download a binary
        "vs-kubernetes" = {
          checkForMinikubeUpgrade = false;
        };
        # open Markdown in the preview, but keep the text diff in diff views
        "workbench.diffEditorAssociations" = {
          "*.md" = "default";
        };
        "workbench.editorAssociations" = {
          "*.md" = "vscode.markdown.preview.editor";
        };
        "workbench.sideBar.experimental.fontSize" = 12;
      };
    };
  };

  # home-manager only registers Nix extensions if it has the package, this copies what it would do
  home.file.".vscode-oss/extensions/.extensions-immutable.json" = {
    text = pkgs.vscode-utils.toExtensionJson config.programs.vscodium.profiles.default.extensions;
    onChange = ''
      run rm $VERBOSE_ARG -f .vscode-oss/extensions/{extensions.json,.init-default-profile-extensions}
      run /opt/homebrew/bin/codium --list-extensions > /dev/null
    '';
  };
}
