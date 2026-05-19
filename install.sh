#!/usr/bin/env bash
# Bootstrap a fresh macOS laptop with all my tools.
# Usage: bash install.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "==> Installing Homebrew (if missing)"
if ! command -v brew >/dev/null 2>&1; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # Add brew to PATH for Apple Silicon
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

echo "==> Installing brew packages, casks, and VS Code extensions from Brewfile"
brew bundle install --file="$SCRIPT_DIR/Brewfile"

echo "==> Installing oh-my-zsh (if missing)"
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

echo "==> Installing oh-my-zsh custom plugins"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
clone_if_missing() {
  local repo="$1" dest="$2"
  [[ -d "$dest" ]] || git clone --depth 1 "$repo" "$dest"
}
clone_if_missing https://github.com/zsh-users/zsh-autosuggestions      "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
clone_if_missing https://github.com/zsh-users/zsh-syntax-highlighting  "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
clone_if_missing https://github.com/zsh-users/zsh-completions          "$ZSH_CUSTOM/plugins/zsh-completions"

echo "==> Done. Run: bash $SCRIPT_DIR/apply-configs.sh   to drop configs into place."
