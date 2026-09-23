# AGENTS.md

Instructions for coding agents setting up a new macOS machine from this repo.
Human-facing docs are in `README.md`; this file covers what an agent must do
differently.

## What this repo is

Personal dotfiles plus three scripts:

| Script | Does |
| --- | --- |
| `install.sh` | Homebrew, Brewfile apps, oh-my-zsh, zsh plugins |
| `apply-configs.sh` | writes `configs/` into `~` and `~/.config`, generates per-machine identity |
| `snapshot.sh` | reverse: pulls the live system state back into `configs/` |

Nothing machine-specific is tracked. Git identity and work-only settings are
generated into `~/.gitconfig.local` and `~/.zshrc.local`, which are untracked.

## Stop and ask the user

Do not guess these. Getting them wrong is the failure this setup exists to
prevent — a wrong answer means commits authored under the wrong identity, or
`trend-ctcs` clones silently broken.

1. **`user.name` and `user.email` for this machine.** Never copy them from
   another machine, from `git log`, or from this repo's history.
2. **Work or personal machine.** `work` adds Trend Micro rules: the
   `trend-ctcs` → `git@github.com-emu:` URL rewrite, the
   `adc.github.trendmicro.com` credential helper, and `GOPRIVATE`.

Never generate SSH keys, edit `~/.ssh/config`, or run `gh auth login` on the
user's behalf without asking — these are credential operations and at least one
is interactive.

## Setup sequence

Run `install.sh` before `gh auth login`; it is what installs `gh`.

```sh
# 1. clone over HTTPS — a fresh machine has no SSH keys yet
git clone https://github.com/uray-lu/devtool_setup.git ~/personal/devtool_setup
cd ~/personal/devtool_setup

# 2. install tooling
bash install.sh

# 3. SSH keys + ~/.ssh/config    -> ask the user, see README
# 4. gh auth login               -> interactive, the user runs it

# 5. apply configs, non-interactively
GIT_NAME="<asked>" GIT_EMAIL="<asked>" MACHINE=work|personal \
  bash apply-configs.sh
```

`apply-configs.sh` prompts when run bare. All three environment variables must
be set together to skip the prompts; `MACHINE` must be exactly `work` or
`personal`. With no terminal and no env vars the script exits with an error
rather than hanging.

## Verify, don't assume

`git config --global` and `git config -f <file>` do **not** follow `[include]`
directives, so they report an empty identity even when everything is correct.
Use normal lookup instead:

```sh
git var GIT_AUTHOR_IDENT                                  # resolved identity
git ls-remote --get-url https://github.com/trend-ctcs/x   # work: git@github.com-emu:...
                                                          # personal: unchanged
```

For `GOPRIVATE`, sandbox `HOME` or the check reads the current shell's
environment and appears to pass on a personal machine:

```sh
env -u GOPRIVATE zsh -ic 'echo $GOPRIVATE'
```

## Gotchas

- **`~/.gitconfig.local` is never overwritten.** If it exists, `apply-configs.sh`
  keeps it and derives work-ness from it. To change identity, delete it and
  re-run. Editing `configs/gitconfig` will not do it.
- **Never add `[user]` to `configs/gitconfig` or `~/.gitconfig`.** `snapshot.sh`
  aborts if `~/.gitconfig` has one, because snapshotting it would commit this
  machine's identity and push it onto the other laptop. A stray
  `git config --global user.email ...` is the usual cause; unset it and move the
  value into `~/.gitconfig.local`.
- **`snapshot.sh` regenerates the Brewfile**, so it picks up unrelated package
  changes. Commit those separately from config changes.
- **The work URL rewrite depends on the `github.com-emu` host alias** in
  `~/.ssh/config`. Applying `MACHINE=work` without that block gives clone
  failures against a host SSH cannot resolve.
