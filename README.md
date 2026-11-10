# dotfiles-lite

Minimal dotfiles for WSL and DevPod: **LazyVim** + **tmux** (with TPM).

## Layout

```
nvim/            -> ~/.config/nvim   (LazyVim, plugins pinned in lazy-lock.json)
tmux/tmux.conf   -> ~/.tmux.conf     (plugins via TPM in ~/.tmux/plugins)
install.sh       symlinks everything, installs nvim/TPM/plugins
```

## Install

### DevPod

DevPod clones the repo and runs `install.sh` automatically:

```sh
devpod up <workspace> --dotfiles git@github.com:<you>/dotfiles-lite.git
# or set it once for all workspaces:
devpod context set-options -o DOTFILES_URL=https://github.com/<you>/dotfiles-lite
```

### WSL

```sh
git clone git@github.com:<you>/dotfiles-lite.git ~/repos/dotfiles-lite
~/repos/dotfiles-lite/install.sh
```

Existing configs are moved to `*.bak.<timestamp>` before linking.

### Options

| Env var           | Effect                                         |
| ----------------- | ---------------------------------------------- |
| `SKIP_PACKAGES=1` | Don't apt/dnf/apk install tmux, ripgrep, fd... |
| `SKIP_PLUGINS=1`  | Don't pre-install nvim and tmux plugins        |

If `nvim` is missing or older than 0.11.2 (LazyVim's minimum), the latest
release is installed to `~/.local/nvim` and linked into `~/.local/bin`.

## Day to day

- **nvim plugins:** `:Lazy` to update; commit `nvim/lazy-lock.json` to pin versions.
- **tmux plugins:** `prefix + I` install, `prefix + U` update, `prefix + r` reload config.
