#!/usr/bin/env bash
# Refresh this repo from the CURRENT system state.
# Run this whenever you change a config and want it captured for sync.
# Usage: bash snapshot.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CFG="$SCRIPT_DIR/configs"

# Identity belongs in ~/.gitconfig.local, not ~/.gitconfig — otherwise snapshot
# commits one machine's name/email and apply-configs.sh pushes it onto the other.
# A stray `git config --global user.email ...` is the usual way this regresses.
if grep -qE '^\[user\]' "$HOME/.gitconfig"; then
  cat >&2 <<EOF
ERROR: ~/.gitconfig has a [user] section. Snapshotting it would commit this
       machine's identity to the repo.

  Move it to ~/.gitconfig.local, then remove it from ~/.gitconfig:
    git config --global --unset user.name
    git config --global --unset user.email
EOF
  exit 1
fi

echo "==> Snapshotting current configs"
mkdir -p "$CFG/nvim" "$CFG/ghostty" "$CFG/fastfetch"
cp "$HOME/.zshrc"                       "$CFG/zshrc"
cp "$HOME/.gitconfig"                   "$CFG/gitconfig"
cp "$HOME/.config/nvim/init.lua"        "$CFG/nvim/init.lua"
cp "$HOME/.config/ghostty/config"       "$CFG/ghostty/config"
cp "$HOME/.config/starship.toml"        "$CFG/starship.toml"
cp "$HOME/.config/fastfetch/config.jsonc" "$CFG/fastfetch/config.jsonc"
cp "$HOME/.config/fastfetch/r-logo.txt" "$CFG/fastfetch/r-logo.txt"
[[ -f "$HOME/.config/git/ignore" ]] && cp "$HOME/.config/git/ignore" "$CFG/git_global_ignore"

echo "==> Regenerating Brewfile"
brew bundle dump --file="$SCRIPT_DIR/Brewfile" --force

echo "==> Done. Review changes with: git -C $SCRIPT_DIR diff"
