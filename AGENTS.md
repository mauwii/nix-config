# AGENTS.md

nix-darwin + home-manager flake for one Mac (aarch64-darwin). Read
[README.md](README.md) for the layout. Everything comes from nixpkgs: no
Homebrew, no `curl | sh`, no manual installs.

## Rules

- Write files, comments and commit messages in English.
- Small change, existing style. One topic per module in `home/`; a new module
  must be added to the `imports` in [home/default.nix](home/default.nix) and
  get a row in the README layout table.
- Prefer a home-manager module (`programs.<name>.enable`) over a bare
  package in `home.packages`. System-wide (`darwin/configuration.nix`) only
  if it cannot work per user.
- Comment only the why, in one line.
- Never put secrets (tokens, API keys, private keys) into this repo; it may
  be pushed to a public remote. Machine-local values go into untracked files such as
  `~/.local/.gitconfig`.
- `git add` new files before building: flakes only see tracked files.
- Do not run `sudo darwin-rebuild switch` and do not commit. Build, then tell
  the user what to run.

## Check a change

```sh
prek run --all-files   # all hooks incl. nixfmt, statix, deadnix; re-run if it fixed files
darwin-rebuild build --flake ~/nix-darwin
```

The build must succeed before you report the change as done. Warnings like
`Git tree ... has uncommitted changes` are normal.

## Find software (replaces `brew search`)

All commands run in `~/nix-darwin`. `--inputs-from .` uses the nixpkgs
version pinned in `flake.lock`, so results match what a build installs.
`2>/dev/null` hides evaluation warnings.

```sh
# search by name or description (regex, case-insensitive)
nix search --inputs-from . nixpkgs 'ripgrep' 2>/dev/null

# exact version of one package
nix eval --inputs-from . --raw nixpkgs#ripgrep.version 2>/dev/null

# does it run on this Mac? (true/false)
nix eval --inputs-from . nixpkgs#ripgrep.meta.platforms \
  --apply 'builtins.elem "aarch64-darwin"' 2>/dev/null

# try it without installing
nix shell --inputs-from . nixpkgs#ripgrep -c rg --version
```

Then check whether home-manager has a module for it (preferred):

```sh
HM=$(nix eval --raw --impure --expr '(builtins.getFlake (toString ./.)).inputs.home-manager.outPath')
ls $HM/modules/programs $HM/modules/services | grep -i ripgrep
less $HM/modules/programs/ripgrep.nix   # the options it accepts
```

nix-darwin options work the same way with `.inputs.nix-darwin.outPath`
(`modules/`).

Notes:

- Attribute names differ from brew names (`kubernetes-helm` not `helm`,
  `signal-desktop` not `signal`). Search by description if a name finds
  nothing.
- GUI apps (brew casks) are in nixpkgs too, often unfree; `allowUnfree` is
  on. Put them in [home/apps.nix](home/apps.nix) and disable their
  self-updater if they have one.
- When replacing an app that is already installed, compare versions: the
  nixpkgs version must not be older (see README).
- Not in nixpkgs or not for aarch64-darwin: tell the user. Do not add
  Homebrew or download binaries.

## Move VSCodium settings into Nix

VSCodium runs with `mutableUserSettings = true`: `settings.json` stays a
normal file and the values in [home/editors.nix](home/editors.nix) are merged
on top on every switch. So the file holds both UI changes and Nix values.

1. Read the current settings:

   ```sh
   cat ~/Library/Application\ Support/VSCodium/User/settings.json
   ```

2. Add the keys that are not yet in `userSettings` in `home/editors.nix`.
   JSON to Nix: `"a.b": true,` becomes `"a.b" = true;`, arrays `[ 1 2 ]`
   without commas, objects `{ "k" = "v"; }`. Keep the full dotted key as a
   quoted string.
3. Skip `update.mode` (set by `enableUpdateCheck = false`), anything
   machine-specific (absolute paths outside `$HOME`, window sizes) and
   anything secret. Never copy `chatLanguageModels.json` or other files with
   credentials.
4. Build. Removing keys from `settings.json` is not needed; Nix values win.

To move a UI-installed extension into Nix:

```sh
codium --list-extensions
# publisher.name -> attribute vscode-extensions.<publisher>.<name>
nix eval --inputs-from . --raw nixpkgs#vscode-extensions.jnoortheen.nix-ide.version 2>/dev/null
```

Add found ones to `profiles.default.extensions = with pkgs.vscode-extensions;
[ ... ];` (the module then needs `pkgs` in its arguments). Extensions
installed from the UI are kept (`mutableExtensionsDir` defaults to true with
only the default profile), so this can be done one extension at a time.

Before the switch, remove the UI copy of a moved extension and fully quit
VSCodium (Cmd+Q), so its folder is really deleted. Otherwise the switch
registers the old folder in `extensions.json` and the extension breaks once
VSCodium deletes it. Fix: quit VSCodium,
`rm ~/.vscode-oss/extensions/extensions.json`, `codium --list-extensions`.
