#!/data/data/com.termux/files/usr/bin/bash
# Set up the minimal Termux backup workstation from this repo.
#
#   git clone <repo> ~/dotfiles
#   ~/dotfiles/termux/bootstrap.sh
#
# Idempotent: safe to re-run. Symlinks configs, installs packages, and
# bootstraps the plugin managers. Does not touch the desktop nix/ tree.

set -euo pipefail

TERMUX_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

info() { printf '\033[0;36m[info]\033[0m %s\n' "$1"; }
ok() { printf '\033[0;32m[ok]\033[0m   %s\n' "$1"; }

link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"

  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    local bak="$dst.bak.$(date +%s)"
    mv "$dst" "$bak"
    ok "backed up existing $dst -> $bak"
  fi

  ln -sfn "$src" "$dst"
  ok "linked $dst"
}

# --- Packages -------------------------------------------------------------
info "installing packages"
pkg install -y \
  fish tmux neovim yazi git lazygit zoxide fzf ripgrep fd bat \
  restic timewarrior openssh keychain termux-api \
  nodejs python clang make tree-sitter \
  lua-language-server marksman taplo shfmt stylua ruff

# --- Language servers / formatters not in the Termux repos --------------
info "installing npm-based language servers and prettier"
npm install -g \
  @vtsls/language-server \
  bash-language-server \
  yaml-language-server \
  vscode-langservers-extracted \
  basedpyright \
  prettier

info "installing mdformat"
pip install --upgrade mdformat mdformat-gfm

# --- Config symlinks ---------------------------------------------------
link "$TERMUX_DIR/fish/config.fish"          "$HOME/.config/fish/config.fish"
link "$TERMUX_DIR/fish/functions/t.fish"     "$HOME/.config/fish/functions/t.fish"
link "$TERMUX_DIR/tmux/tmux.conf"            "$HOME/.config/tmux/tmux.conf"
link "$TERMUX_DIR/yazi/yazi.toml"            "$HOME/.config/yazi/yazi.toml"
link "$TERMUX_DIR/yazi/keymap.toml"          "$HOME/.config/yazi/keymap.toml"
link "$TERMUX_DIR/nvim"                      "$HOME/.config/nvim"
link "$TERMUX_DIR/gitconfig"                 "$HOME/.gitconfig"
link "$TERMUX_DIR/claude/CLAUDE.md"          "$HOME/.claude/CLAUDE.md"
link "$TERMUX_DIR/restic/restic.sh"          "$HOME/.local/bin/restic.sh"

# --- Claude settings merge (install.sh owns the file, so merge not link)
if [ -f "$HOME/.claude/settings.json" ]; then
  tmp="$(mktemp)"
  jq '. + {includeCoAuthoredBy: false, model: "opus"}' "$HOME/.claude/settings.json" > "$tmp"
  cat "$tmp" > "$HOME/.claude/settings.json"
  rm -f "$tmp"
  ok "merged claude settings (model=opus, includeCoAuthoredBy=false)"
fi

# --- fish plugins --------------------------------------------------
if ! fish -c 'type -q fisher' 2>/dev/null; then
  info "installing fisher + plugins"
  fish -c '
    curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
    fisher install jorgebucaran/fisher
    fisher install jorgebucaran/hydro
    fisher install franciscolourenco/done
  '
  ok "fish plugins installed"
fi

# --- Neovim plugins ------------------------------------------------
info "syncing neovim plugins"
nvim --headless "+Lazy! sync" +qa || true

info "installing treesitter parsers (blocks until done, up to 5 min)"
nvim --headless -c 'lua vim.wait(300000, function()
  local ok, ts = pcall(require, "nvim-treesitter")
  if not ok then return false end
  local have = {}
  for _, p in ipairs(ts.get_installed()) do have[p] = true end
  for _, p in ipairs({ "bash", "lua", "python", "typescript", "tsx", "json", "yaml", "toml", "markdown", "vim", "query" }) do
    if not have[p] then return false end
  end
  return true
end, 1000)' -c qa || true

# --- Default shell -----------------------------------------------
if [ "$(basename "${SHELL:-}")" != "fish" ]; then
  chsh -s fish && ok "default shell set to fish (restart Termux)"
fi

cat <<DONE

Done. Restart Termux, then:

  - fish is your shell
  - 't <dir>' opens a tmux session with nvim + a shell split
  - restic: fill in ~/.local/share/restic/{password,repository,env}, then
    'restic.sh snap' to list snapshots, 'restic.sh pull Documents' to restore

DONE
