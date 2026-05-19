#!/usr/bin/env bash
# Copy configs from this repo into the right locations on the system.
# Existing files are backed up to <file>.bak-YYYYMMDD-HHMMSS before overwrite.
# Usage: bash apply-configs.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CFG="$SCRIPT_DIR/configs"
STAMP="$(date +%Y%m%d-%H%M%S)"

backup_and_copy() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [[ -e "$dst" && ! -L "$dst" ]]; then
    cp "$dst" "$dst.bak-$STAMP"
    echo "  backed up $dst -> $dst.bak-$STAMP"
  fi
  cp "$src" "$dst"
  echo "  wrote $dst"
}

echo "==> Applying configs"
backup_and_copy "$CFG/zshrc"                    "$HOME/.zshrc"
backup_and_copy "$CFG/gitconfig"                "$HOME/.gitconfig"
backup_and_copy "$CFG/nvim/init.lua"            "$HOME/.config/nvim/init.lua"
backup_and_copy "$CFG/ghostty/config"           "$HOME/.config/ghostty/config"
backup_and_copy "$CFG/starship.toml"            "$HOME/.config/starship.toml"
backup_and_copy "$CFG/fastfetch/config.jsonc"   "$HOME/.config/fastfetch/config.jsonc"
backup_and_copy "$CFG/fastfetch/r-logo.txt"     "$HOME/.config/fastfetch/r-logo.txt"
backup_and_copy "$CFG/git_global_ignore"        "$HOME/.config/git/ignore"

echo "==> Done. Open a new terminal so .zshrc takes effect."
