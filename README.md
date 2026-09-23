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

For unattended runs (agents, CI), skip the prompts with environment variables:

```sh
GIT_NAME="Ray Lu" GIT_EMAIL=me@example.com MACHINE=personal bash apply-configs.sh
```

`MACHINE` must be `work` or `personal`. All three are required together;
otherwise the script prompts.

The `.work` overlays carry Trend Micro settings: the `trend-ctcs` →
`git@github.com-emu:` URL rewrite, the `adc.github.trendmicro.com` credential
helper, and `GOPRIVATE`. The URL rewrite depends on the `github.com-emu` host
alias in the work `~/.ssh/config`; applying it on a personal machine would
silently break `trend-ctcs` clones, which is why it is opt-in per machine.

## On a new laptop

Three things live outside this repo and have to be done by hand: **SSH keys**,
`~/.ssh/config`, and `gh` auth. Everything else is scripted.

**1. Clone over HTTPS.** The `origin` remote is SSH, but a fresh machine has no
keys yet, so an SSH clone fails. (macOS prompts to install the Xcode command
line tools if `git` is missing — accept.)

```sh
git clone https://github.com/uray-lu/devtool_setup.git ~/personal/devtool_setup
cd ~/personal/devtool_setup
```

**2. Install everything.** This is what puts `gh` on the machine, so it must
come before step 4.

```sh
bash install.sh
```

**3. SSH keys and `~/.ssh/config`.** Generate a key and add it to GitHub:

```sh
ssh-keygen -t ed25519 -C "your-email" -f ~/.ssh/id_rsa_personal
gh auth login    # or paste ~/.ssh/id_rsa_personal.pub into GitHub → Settings → SSH keys
```

Then write `~/.ssh/config`. On a **personal** machine that is all you need:

```
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_rsa_personal
```

A **work** machine also needs the `github.com-emu` alias, because
`configs/gitconfig.work` rewrites `trend-ctcs` URLs to it — without this block
those clones break:

```
Host github.com-emu
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_trend_emu
    IdentitiesOnly yes
```

Copy the matching private keys over, `chmod 600` them, and check with
`ssh -T git@github.com`.

**4. Log in to `gh`.** The credential helpers in `configs/gitconfig` shell out
to `gh auth git-credential`, so HTTPS operations fail until this is done. Work
machines need it twice:

```sh
gh auth login
gh auth login --hostname adc.github.trendmicro.com   # work only
```

**5. Apply configs.** Prompts for `user.name`, `user.email`, and whether this is
a work machine. Answer **n** on a personal machine.

```sh
bash apply-configs.sh
```

**6. Verify.**

```sh
git var GIT_AUTHOR_IDENT                                  # this machine's identity
git ls-remote --get-url https://github.com/trend-ctcs/x   # personal: unchanged
                                                          # work: git@github.com-emu:...
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
