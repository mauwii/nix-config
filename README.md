# nix-darwin

macOS configuration with [nix-darwin](https://github.com/nix-darwin/nix-darwin)
and [home-manager](https://github.com/nix-community/home-manager), as a flake.
No Homebrew: everything comes from nixpkgs.

## Layout

| Path | Purpose |
| --- | --- |
| [`flake.nix`](flake.nix) | Inputs (nixpkgs-unstable, nix-darwin, home-manager), user and host name |
| [`darwin/configuration.nix`](darwin/configuration.nix) | System settings: user, shells, system packages |
| [`home/default.nix`](home/default.nix) | home-manager entry point: imports, XDG, session variables, fonts |
| [`home/apps.nix`](home/apps.nix) | GUI apps (iTerm2, LM Studio, Signal) |
| [`home/zsh.nix`](home/zsh.nix) | zsh: history, completion, plugins, aliases |
| [`home/starship.nix`](home/starship.nix) | Starship prompt, settings in [`home/starship.toml`](home/starship.toml) |
| [`home/git.nix`](home/git.nix) | git settings, identity, SSH commit signing, global ignores |
| [`home/cli.nix`](home/cli.nix) | direnv (with nix-direnv), eza |
| [`home/dev.nix`](home/dev.nix) | Dev tools, node, uv, gh, Claude Code |
| [`home/docker.nix`](home/docker.nix) | Docker CLI with colima as runtime (launchd agent) |
| [`home/editors.nix`](home/editors.nix) | neovim, VSCodium |
| [`.pre-commit-config.yaml`](.pre-commit-config.yaml) | Hooks: whitespace, YAML, gitleaks, actionlint, nixfmt |
| [`.github/`](.github/) | CI, weekly update PRs, Dependabot |

## CI and hooks

Hooks run with [prek](https://github.com/j178/prek), a drop-in replacement
for pre-commit that reads the same `.pre-commit-config.yaml` (nixpkgs'
pre-commit fails to create Python hook environments). After cloning, install
the git hooks once:

```sh
prek install
prek run --all-files   # run all hooks by hand
```

GitHub Actions (all jobs on macOS runners, free for public repos):

- **Every push and PR**: all hooks, then a full build of the darwin
  configuration.
- **Every Monday**: PRs that update `flake.lock` and the pre-commit hook
  versions; Dependabot does the same for the GitHub Actions. After merging a
  `flake.lock` update, pull and run `sudo darwin-rebuild switch`.

PRs opened by a workflow with the default `GITHUB_TOKEN` do not start CI. To
get CI on update PRs, create a fine-grained token (this repo
only, *Contents* and *Pull requests*: read and write) and store it with
`gh secret set UPDATE_TOKEN`. Without it, close and reopen the PR to start
CI.

## Daily use

```sh
# apply changes
sudo darwin-rebuild switch --flake ~/nix-darwin

# build only, to check that the config evaluates and builds
darwin-rebuild build --flake ~/nix-darwin

# update all inputs (nixpkgs, nix-darwin, home-manager), then apply
nix flake update --flake ~/nix-darwin
sudo darwin-rebuild switch --flake ~/nix-darwin

# something broke: go back to the previous generation
sudo darwin-rebuild --rollback
```

Flakes only see files tracked by git, so `git add` new files before
rebuilding.

## Adding software

- Prefer a home-manager module (`programs.<name>`, search the
  [options](https://home-manager-options.extranix.com/)), otherwise add the
  package to `home.packages` in a module in [`home/`](home/).
- Libraries such as `opencv` belong in a project's devShell (`flake.nix` +
  `.envrc` with `use flake`), not in the user profile.

When replacing an app installed some other way by its Nix package, check that
the Nix version is not older than the installed one: apps like Signal refuse
data written by a newer version.

## Setting up a new Mac

1. Install [Determinate Nix](https://docs.determinate.systems/):

   ```sh
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
   ```

2. Clone this repository to `~/nix-darwin`. The configuration is selected by
   `scutil --get LocalHostName`. On a different host, add an entry in
   [`flake.nix`](flake.nix) or pass `--flake ~/nix-darwin#<name>`.
3. Move the shell files that the Nix installer modified out of the way,
   otherwise nix-darwin refuses to overwrite them:

   ```sh
   for f in zshrc zshenv bashrc; do sudo mv /etc/$f /etc/$f.before-nix-darwin; done
   ```

4. Do the first activation (afterwards `darwin-rebuild` is in the PATH):

   ```sh
   sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake ~/nix-darwin
   ```

5. Open a new terminal. If `~/Library/Fonts` did not exist before, log out
   and back in (or run `killall fontd`) so macOS picks up the fonts.

## Good to know

- **Determinate Nix** manages the Nix daemon and `/etc/nix/nix.conf`, so
  nix-darwin runs with `nix.enable = false`. Custom Nix settings go into
  `/etc/nix/nix.custom.conf`.
- **Apps** from Nix are copied to `~/Applications/Home Manager Apps` and do
  not update themselves; updates come with `nix flake update`.
- **Files home-manager replaces** are kept with the suffix
  `.before-home-manager`.
- **zsh** reads its config from `~/.config/zsh` and keeps its history in
  `~/.local/state/zsh/history`.
- **npm** installs global packages into `~/.local/share/npm` because the Nix
  store is read-only.
- **git identity** and other machine-local git settings go into
  `~/.local/.gitconfig` (untracked, included by the global config).
