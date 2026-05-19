# tool_setup

Personal dotfiles + bootstrap scripts for setting up a macOS laptop.

## Layout

```
tool_setup/
├── Brewfile              # brew formulae, casks, and VS Code extensions
├── install.sh            # set up a fresh machine: brew + apps + oh-my-zsh + plugins
├── apply-configs.sh      # copy configs from configs/ into ~ and ~/.config
├── snapshot.sh           # refresh this repo from current system state
└── configs/
    ├── zshrc             # → ~/.zshrc
    ├── gitconfig         # → ~/.gitconfig
    ├── git_global_ignore # → ~/.config/git/ignore
    ├── starship.toml     # → ~/.config/starship.toml
    ├── nvim/init.lua     # → ~/.config/nvim/init.lua
    ├── ghostty/config    # → ~/.config/ghostty/config
    └── fastfetch/        # → ~/.config/fastfetch/
```

## On a new laptop

```sh
git clone <this-repo-url> ~/personal/tool_setup
cd ~/personal/tool_setup
bash install.sh          # installs Homebrew, all apps, oh-my-zsh, plugins
bash apply-configs.sh    # writes configs to their real locations
```

Open a new terminal — done.

## When you change a config on your current laptop

```sh
cd ~/personal/tool_setup
bash snapshot.sh         # pulls latest configs + regenerates Brewfile
git add -A && git commit -m "update configs" && git push
```

Then on your other laptop: `git pull && bash apply-configs.sh`.

## Notes

- `apply-configs.sh` backs up any existing file as `<file>.bak-<timestamp>` before overwriting, so it's safe to re-run.
- SSH keys are NOT in this repo. Copy `~/.ssh/` manually or set up new keys per machine.
- oh-my-zsh itself is installed by `install.sh`; the zsh plugins (`zsh-autosuggestions`, `zsh-syntax-highlighting`, `zsh-completions`) are cloned into `$ZSH_CUSTOM/plugins/`.
- To put this on GitHub: `cd ~/personal/tool_setup && git init && gh repo create tool_setup --private --source=. --push`.
