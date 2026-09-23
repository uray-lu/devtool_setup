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
    ├── zshrc.work        # sourced by ~/.zshrc.local on work machines only
    ├── gitconfig         # → ~/.gitconfig
    ├── gitconfig.work    # included by ~/.gitconfig.local on work machines only
    ├── git_global_ignore # → ~/.config/git/ignore
    ├── starship.toml     # → ~/.config/starship.toml
    ├── nvim/init.lua     # → ~/.config/nvim/init.lua
    ├── ghostty/config    # → ~/.config/ghostty/config
    └── fastfetch/        # → ~/.config/fastfetch/
```

## Per-machine settings

Nothing machine-specific is tracked in this repo. `apply-configs.sh` prompts for
your git `user.name` / `user.email` and whether this is a work machine, then
generates two untracked files:

| File | Holds |
| --- | --- |
| `~/.gitconfig.local` | `[user]` identity; on work machines, `[include]` of `configs/gitconfig.work` |
| `~/.zshrc.local` | on work machines, `source` of `configs/zshrc.work` |

`configs/gitconfig` ends with `[include] path = ~/.gitconfig.local`, so identity
always wins over anything shared. Re-running `apply-configs.sh` leaves an existing
`~/.gitconfig.local` alone — **delete it and re-run to change identity.**

The `.work` overlays carry Trend Micro settings: the `trend-ctcs` →
`git@github.com-emu:` URL rewrite, the `adc.github.trendmicro.com` credential
helper, and `GOPRIVATE`. The URL rewrite depends on the `github.com-emu` host
alias in the work `~/.ssh/config`; applying it on a personal machine would
silently break `trend-ctcs` clones, which is why it is opt-in per machine.

## On a new laptop

```sh
git clone <this-repo-url> ~/personal/tool_setup
cd ~/personal/tool_setup
bash install.sh          # installs Homebrew, all apps, oh-my-zsh, plugins
bash apply-configs.sh    # prompts for git identity, writes configs into place
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
- `snapshot.sh` aborts if `~/.gitconfig` has grown a `[user]` section — usually from a stray `git config --global user.email ...`. Move it to `~/.gitconfig.local` and `git config --global --unset` it, or the next `apply-configs.sh` pushes that identity onto your other laptop.
- SSH keys are NOT in this repo. Copy `~/.ssh/` manually or set up new keys per machine.
- oh-my-zsh itself is installed by `install.sh`; the zsh plugins (`zsh-autosuggestions`, `zsh-syntax-highlighting`, `zsh-completions`) are cloned into `$ZSH_CUSTOM/plugins/`.
- To put this on GitHub: `cd ~/personal/tool_setup && git init && gh repo create tool_setup --private --source=. --push`.
