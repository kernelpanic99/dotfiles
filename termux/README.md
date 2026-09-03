# Termux backup workstation

A minimal CLI workstation for Termux on aarch64 Android (glibc repo enabled),
ported from the NixOS/home-manager config in `../nix`. No nix-on-droid, no
proot-distro: native Termux packages plus plain dotfiles.

## Setup

```sh
git clone <repo> ~/dotfiles
~/dotfiles/termux/bootstrap.sh
```

`bootstrap.sh` is idempotent. It installs packages, symlinks the configs
below into `~/.config`, and bootstraps fisher / lazy.nvim.

## What is here

| Area | Config | Notes |
|---|---|---|
| Shell | `fish/` | `t` session launcher, timewarrior aliases, `nt`, keychain ssh-agent |
| Multiplexer | `tmux/` | prefix `C-s`, vi mode, inline catppuccin status + vim-tmux-navigator (no tpm), `y` copies to Android clipboard |
| Files | `yazi/` | smart-enter/paste, ouch previews, `y` copies path via `termux-clipboard-set` |
| Editor | `nvim/` | lazy.nvim; ts/js, lua, python, bash, json/yaml/toml, markdown |
| Git | `gitconfig` | name + sane defaults |
| Claude | `claude/CLAUDE.md` | rules from `nix/config/claude.nix`; settings merged by bootstrap |
| Restore | `restic/` | `restic.sh` pulls desktop backups down; local backup is a subcommand |

## Neovim

Plugin set: treesitter, blink.cmp, snacks (picker/lazygit/notifier/indent),
gitsigns, neo-tree, lualine, barbar, which-key, mini.pairs/ai, render-markdown,
conform, sidekick (claude only).

LSP: `vtsls`, `lua_ls`, `basedpyright`, `bashls`, `yamlls`, `jsonls`,
`marksman`, `taplo`. Formatters: `stylua`, `ruff`, `prettier`, `shfmt`,
`mdformat`.

## restic

Restore-focused: the desktop backs up to this repo, the tablet pulls things
back down. `restic.sh` reads the repo, password, and S3 credentials from
`~/.local/share/restic/`.

```sh
mkdir -p ~/.local/share/restic && chmod 700 ~/.local/share/restic
echo 'PASSWORD' > ~/.local/share/restic/password
echo 'REPO_URL' > ~/.local/share/restic/repository
printf 'AWS_ACCESS_KEY_ID=...\nAWS_SECRET_ACCESS_KEY=...\n' > ~/.local/share/restic/env
chmod 600 ~/.local/share/restic/{password,repository,env}
```

```sh
restic.sh snap                       # list snapshots
restic.sh ls Documents               # browse a path in the latest snapshot
restic.sh find '*.kdbx'              # locate a file across snapshots
restic.sh pull Documents             # restore ~/Documents from the desktop
restic.sh pull .ssh                  # -> ~/.ssh
restic.sh pull Pictures/Wallpapers ~/wp
restic.sh cat Documents/notes/x.md   # stream one file to stdout
restic.sh backup                     # local backup of this device
```

Paths are relative to the desktop home (`/home/kp`); override with
`RESTIC_DESKTOP_HOME`. `restic.sh` is on `PATH` via `~/.local/bin`. Anything
not a known subcommand passes straight through to `restic`.

## Not migrated

The desktop/system layer: niri, noctalia, foot, wayland tooling, flatpak apps,
brave, keepassxc, steam, ollama, GTK/Qt theming, boot/disko, pipewire,
bluetooth. Also dropped by choice: delta, direnv, fastfetch, yt-dlp, mpd/rmpc,
crush, btop (`htop` is installed instead).
