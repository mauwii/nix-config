# nix-config

macOS configuration with [nix-darwin](https://github.com/nix-darwin/nix-darwin)
and [home-manager](https://github.com/nix-community/home-manager), as a flake.
Nix configures, Homebrew delivers the programs, both declared here.

## Layout

| Path | Purpose |
| --- | --- |
| [`flake.nix`](flake.nix) | Inputs (nixpkgs-unstable, nix-darwin, home-manager, nix-homebrew), user, one configuration per Mac |
| [`darwin/configuration.nix`](darwin/configuration.nix) | System settings: user, shells |
| [`darwin/homebrew.nix`](darwin/homebrew.nix) | Homebrew itself, formulae, casks and App Store apps for all Macs |
| [`profiles/private.nix`](profiles/private.nix) | What only private Macs get: apps, Cline, default git email |
| [`hosts/atlas.nix`](hosts/atlas.nix) | M4 Max: host name, CleanMyMac with license (cask) |
| [`hosts/kronos.nix`](hosts/kronos.nix) | M2 Max: host name, CleanMyMac from the App Store |
| [`home/default.nix`](home/default.nix) | home-manager entry point: imports, XDG, session variables |
| [`home/apps.nix`](home/apps.nix) | Defaults of GUI apps: iTerm2 updater, default profile (Dynamic Profile) |
| [`home/zsh.nix`](home/zsh.nix) | zsh: history, completion, plugins, aliases |
| [`home/starship.nix`](home/starship.nix) | Starship prompt, settings in [`home/starship.toml`](home/starship.toml) |
| [`home/git.nix`](home/git.nix) | git settings, identity per remote, SSH commit signing, global ignores |
| [`home/cli.nix`](home/cli.nix) | bat (also as man pager), direnv (with nix-direnv), eza, topgrade |
| [`home/dev.nix`](home/dev.nix) | gh, npm prefix, tenv |
| [`home/docker.nix`](home/docker.nix) | Docker CLI with colima as runtime (launchd agent) |
| [`home/editors.nix`](home/editors.nix) | neovim (config in [`home/nvim/`](home/nvim/), plugins from nixpkgs), VSCodium |
| [`home/keyboard.nix`](home/keyboard.nix) | macOS system hotkeys (window switching) |
| [`.pre-commit-config.yaml`](.pre-commit-config.yaml) | Hooks: whitespace, YAML, gitleaks, actionlint, nixfmt, statix, deadnix |
| [`statix.toml`](statix.toml) | statix lints that do not fit the repo style |
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

- **Every push and PR**: all hooks, then a full build of every configuration.
  It installs nothing from Homebrew; `brew info` checks that every formula
  and cask name exists.
- **Every Monday**: PRs that update `flake.lock` and the pre-commit hook
  versions; Dependabot does the same for the GitHub Actions, which are pinned
  to commit SHAs because a tag can be moved. After merging a
  `flake.lock` update, pull and switch (see [Daily use](#daily-use)).

PRs opened by a workflow with the default `GITHUB_TOKEN` do not start CI. To
get CI on update PRs, create a fine-grained token (this repo
only, *Contents* and *Pull requests*: read and write) and store it with
`gh secret set UPDATE_TOKEN`. Without it, close and reopen the PR to start
CI.

## Daily use

Every command names the configuration of the Mac, there is no default. Each
is named like the host name it sets: `atlas` (M4 Max) and `kronos` (M2 Max).
The examples use `atlas`.

```sh
# apply changes; after adding formulae or casks run `brew update` first
sudo darwin-rebuild switch --flake ~/git/mauwii/nix-config#atlas

# build only, to check that the config evaluates and builds
darwin-rebuild build --flake ~/git/mauwii/nix-config#atlas

# update the programs from Homebrew and the Docker engine (restarts Docker)
topgrade

# update all inputs (nixpkgs, nix-darwin, home-manager, nix-homebrew), then apply
nix flake update --flake ~/git/mauwii/nix-config
sudo darwin-rebuild switch --flake ~/git/mauwii/nix-config#atlas

# something broke: go back to the previous generation (not for Homebrew packages);
# first `brew uninstall` what the last switch added, see below
sudo darwin-rebuild --rollback
```

Flakes only see files tracked by git, so `git add` new files before
rebuilding.

| What | Updated by |
| --- | --- |
| Formulae, casks, fonts | `topgrade`; apps with an updater also update themselves |
| Docker engine in colima, uv tools, global npm packages | `topgrade` (colima must be running) |
| Configuration and the few programs from Nix | `flake.lock`, then a switch |

If `brew bundle` fails during a switch, programs that moved from Nix to
Homebrew are missing until a switch succeeds or you roll back.

Every activation, a rollback too, aborts if Homebrew has packages that its
Brewfile does not list. So before a rollback, `brew uninstall` the packages
the error lists; otherwise each retry of the rollback steps one generation
further back, while the system stays where it was. Never run the
`brew bundle cleanup --force` it suggests: it removes every unlisted cask and
formula at once.

## Adding software

[AGENTS.md](AGENTS.md) describes the workflow, written so that an LLM can
follow it.

- Programs go into [`darwin/homebrew.nix`](darwin/homebrew.nix) (all Macs) or
  [`profiles/private.nix`](profiles/private.nix). `brew install` by hand makes
  the next switch abort, and so does an App Store app missing in `masApps`.
- Configuration goes into a home-manager module (`programs.<name>`, search the
  [options](https://home-manager-options.extranix.com/)) in [`home/`](home/).
- Casks without a checksum are refused.
- Libraries such as `opencv` belong in a project's devShell (`flake.nix` +
  `.envrc` with `use flake`), not in the user profile.

When replacing an installed app, check that the new version is not older:
apps like Signal refuse data written by a newer version.

## Setting up a new Mac

1. Install the Command Line Tools (`xcode-select --install`, Homebrew needs
   them) and [Determinate Nix](https://docs.determinate.systems/):

   ```sh
   curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
   ```

2. Clone this repository to `~/git/mauwii/nix-config`. A new Mac needs a file
   in [`hosts/`](hosts/) and a configuration in [`flake.nix`](flake.nix).
   `profiles/private.nix` is only for private Macs; a work Mac needs a
   configuration without it, and the email rule
   from [Work Macs](#work-macs).
3. Move the shell files that the Nix installer modified out of the way,
   otherwise nix-darwin refuses to overwrite them:

   ```sh
   for f in zshrc zshenv bashrc; do sudo mv /etc/$f /etc/$f.before-nix-darwin; done
   ```

4. Do the first activation (afterwards `darwin-rebuild` is in the PATH):

   ```sh
   sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake ~/git/mauwii/nix-config#<host>
   ```

5. Open a new terminal. If `~/Library/Fonts` did not exist before, log out
   and back in (or run `killall fontd`) so macOS picks up the fonts.
6. Put the SSH key into `~/.ssh/id_ed25519` and `~/.ssh/id_ed25519.pub`, for
   example copied from the old Mac: git signs every commit with it and refuses
   to commit without it. A new key must also replace the one in
   `allowedSigners` in [`home/git.nix`](home/git.nix) and be added to GitHub
   as a signing key.

## Work Macs

git takes the GitHub email only in repos with a remote on GitHub and refuses
to commit where it knows no email. Add the company email to the untracked
`~/.local/.gitconfig`, for every SSH and HTTPS form of the host. Without it,
a company repo with a second remote on GitHub commits with the GitHub email.

```ini
[includeIf "hasconfig:remote.*.url:git@gitlab.example.com:*/**"]
  path = ~/.local/work.gitconfig
[includeIf "hasconfig:remote.*.url:https://gitlab.example.com/**"]
  path = ~/.local/work.gitconfig
[includeIf "hasconfig:remote.*.url:ssh://git@gitlab.example.com/**"]
  path = ~/.local/work.gitconfig
# with a port; not `gitlab.example.com*/**`, that also matches other hosts
[includeIf "hasconfig:remote.*.url:ssh://git@gitlab.example.com:*/**"]
  path = ~/.local/work.gitconfig
```

`~/.local/work.gitconfig` then holds the `email` in a `[user]` section.

## Good to know

- **Determinate Nix** manages the Nix daemon and `/etc/nix/nix.conf`, so
  nix-darwin runs with `nix.enable = false`. Custom Nix settings go into
  `/etc/nix/nix.custom.conf`.
- **Homebrew** is installed by nix-homebrew and pinned in `flake.lock`; its
  packages are not pinned. Its `bin` comes after Nix and before `/usr/bin`.
- **Files home-manager replaces** are kept with the suffix
  `.before-home-manager`.
- **zsh** reads its config from `~/.config/zsh` and keeps its history in
  `~/.local/state/zsh/history`.
- **npm** installs global packages into `~/.local/share/npm`, outside the
  prefix that Homebrew manages.
- **Work identities** and other machine-local git settings go into
  `~/.local/.gitconfig` (untracked, included by the global config).
