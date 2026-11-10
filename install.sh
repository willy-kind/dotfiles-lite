#!/usr/bin/env bash
# Dotfiles installer for WSL and DevPod.
# DevPod runs this automatically:  devpod up <repo> --dotfiles https://github.com/willy-kind/dotfiles-lite
# WSL: clone the repo and run ./install.sh
#
# Env flags:
#   SKIP_PACKAGES=1   don't try to install system packages
#   SKIP_PLUGINS=1    don't pre-install nvim / tmux plugins
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_BIN="$HOME/.local/bin"
NVIM_MIN="0.11.2" # LazyVim minimum

log() { printf '\033[1;32m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m==>\033[0m %s\n' "$*" >&2; }
have() { command -v "$1" >/dev/null 2>&1; }

# Symlink $1 (in repo) to $2, backing up anything already there.
link() {
  local src="$DOTFILES/$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  if [ -L "$dst" ]; then
    rm "$dst"
  elif [ -e "$dst" ]; then
    local bak="$dst.bak.$(date +%Y%m%d%H%M%S)"
    warn "backing up $dst -> $bak"
    mv "$dst" "$bak"
  fi
  ln -s "$src" "$dst"
  log "linked $dst -> $src"
}

# Root runs directly; passwordless sudo (DevPod) runs silently; on an
# interactive terminal (WSL) sudo may prompt for the password.
sudo_cmd() {
  if [ "$(id -u)" -eq 0 ]; then "$@"
  elif have sudo && sudo -n true 2>/dev/null; then sudo "$@"
  elif have sudo && [ -t 0 ]; then sudo "$@"
  else return 1; fi
}

install_packages() {
  [ "${SKIP_PACKAGES:-0}" = 1 ] && return
  local pkgs=(git tmux curl unzip ripgrep fd-find fzf make gcc)
  if have apt-get; then
    sudo_cmd env DEBIAN_FRONTEND=noninteractive apt-get update -qq &&
      sudo_cmd env DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "${pkgs[@]}" ||
      warn "apt install failed (no sudo?), skipping packages"
    # Debian names it fdfind
    if have fdfind && ! have fd; then mkdir -p "$LOCAL_BIN"; ln -sf "$(command -v fdfind)" "$LOCAL_BIN/fd"; fi
  elif have dnf; then
    sudo_cmd dnf install -y -q git tmux curl unzip ripgrep fd-find fzf make gcc ||
      warn "dnf install failed, skipping packages"
  elif have apk; then
    sudo_cmd apk add --no-cache git tmux curl unzip ripgrep fd fzf make gcc musl-dev ||
      warn "apk install failed, skipping packages"
  else
    warn "unknown package manager; install tmux, git, ripgrep, fd, fzf manually"
  fi
}

version_ge() { [ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -1)" = "$2" ]; }

install_nvim() {
  if have nvim; then
    local v
    v="$(nvim --version | head -1 | sed -E 's/^NVIM v([0-9.]+).*/\1/')"
    version_ge "$v" "$NVIM_MIN" && { log "nvim $v ok"; return; }
    warn "nvim $v is older than $NVIM_MIN, installing newer one to ~/.local"
  fi
  if have apk; then
    warn "official nvim builds need glibc; on Alpine run: apk add neovim"
    return
  fi
  local arch
  case "$(uname -m)" in
    x86_64) arch=x86_64 ;;
    aarch64 | arm64) arch=arm64 ;;
    *) warn "no nvim release for $(uname -m); install it manually"; return ;;
  esac
  local tmp
  tmp="$(mktemp -d)"
  curl -fsSL "https://github.com/neovim/neovim/releases/latest/download/nvim-linux-${arch}.tar.gz" |
    tar -xz -C "$tmp"
  rm -rf "$HOME/.local/nvim"
  mkdir -p "$HOME/.local" "$LOCAL_BIN"
  mv "$tmp/nvim-linux-${arch}" "$HOME/.local/nvim"
  ln -sf "$HOME/.local/nvim/bin/nvim" "$LOCAL_BIN/nvim"
  rm -rf "$tmp"
  log "installed $("$LOCAL_BIN/nvim" --version | head -1) to ~/.local/bin"
}

ensure_path() {
  case ":$PATH:" in *":$LOCAL_BIN:"*) return ;; esac
  export PATH="$LOCAL_BIN:$PATH"
  local rc
  for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
    [ -f "$rc" ] || continue
    grep -q 'dotfiles-lite: local bin' "$rc" ||
      printf '\n# dotfiles-lite: local bin\nexport PATH="$HOME/.local/bin:$PATH"\n' >>"$rc"
  done
}

# Debian/Ubuntu's default .bashrc sources ~/.bash_aliases; Fedora's doesn't
ensure_bash_aliases() {
  local rc="$HOME/.bashrc"
  [ -f "$rc" ] || return 0
  grep -q '\.bash_aliases' "$rc" ||
    printf '\n# dotfiles-lite: aliases\n[ -f ~/.bash_aliases ] && . ~/.bash_aliases\n' >>"$rc"
}

install_tpm() {
  local tpm="$HOME/.tmux/plugins/tpm"
  if [ ! -d "$tpm" ]; then
    git clone --depth 1 https://github.com/tmux-plugins/tpm "$tpm"
  fi
  [ "${SKIP_PLUGINS:-0}" = 1 ] && return
  have tmux || return 0
  # TPM reads the plugin list from a running server, so start a throwaway one if needed
  local tmp_session=""
  if ! tmux has-session 2>/dev/null; then
    tmp_session="__dotfiles_install"
    tmux new-session -d -s "$tmp_session"
  fi
  "$tpm/bin/install_plugins" >/dev/null && log "tmux plugins installed" ||
    warn "tmux plugin install failed; press prefix + I inside tmux"
  [ -n "$tmp_session" ] && tmux kill-session -t "$tmp_session" 2>/dev/null || true
}

install_nvim_plugins() {
  [ "${SKIP_PLUGINS:-0}" = 1 ] && return
  have nvim || return 0
  log "syncing nvim plugins (lazy.nvim, from lazy-lock.json)"
  nvim --headless "+Lazy! restore" +qa >/dev/null 2>&1 ||
    warn "nvim plugin sync failed; open nvim and run :Lazy"
}

main() {
  install_packages
  ensure_path
  install_nvim

  link nvim "$HOME/.config/nvim"
  link tmux/tmux.conf "$HOME/.tmux.conf"
  link bash/aliases.sh "$HOME/.bash_aliases"
  ensure_bash_aliases

  install_tpm
  install_nvim_plugins
  log "done"
}

main "$@"
