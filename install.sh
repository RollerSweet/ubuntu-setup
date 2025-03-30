#!/usr/bin/env bash
set -euo pipefail

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()    { echo -e "${GREEN}[INFO]${NC} $1"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1"; }

# Get absolute path of the script directory
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check for sudo
if [[ "$EUID" -ne 0 ]]; then
  error "Please run as root (e.g., sudo ./install.sh)"
  exit 1
fi

info "Updating and upgrading packages..."
apt-get update && apt-get upgrade -yqq

info "Installing base packages..."
apt-get install -yqq golang
wget https://github.com/derailed/k9s/releases/latest/download/k9s_linux_amd64.deb && apt install ./k9s_linux_amd64.deb && rm k9s_linux_amd64.deb

# === Scripts ===
SCRIPTS=(
  fonts
  zsh_omzsh
  tmux_tpm
  ghostty
  alacritty
  bat
  neovim
  lazygit
  lazydocker
  kubectl
  fzf
)

for script in "${SCRIPTS[@]}"; do
  path="${BASE_DIR}/scripts/${script}.sh"
  if [[ -x "$path" || -f "$path" ]]; then
    info "Running ${script}.sh"
    bash "$path"
  else
    warn "Script ${script}.sh not found, skipping."
  fi
done

# === Configs ===
info "Setting up configs..."

mkdir -p ~/.config/{tmux,nvim}

TMUX_CONF="${BASE_DIR}/configs/tmux/tmux.conf"
NVIM_CONFIG="${BASE_DIR}/configs/nvim"

if [[ -f "$TMUX_CONF" ]]; then
  cp "$TMUX_CONF" ~/.config/tmux/tmux.conf
else
  warn "tmux.conf not found"
fi

if [[ -d "$NVIM_CONFIG" ]]; then
  cp -r "$NVIM_CONFIG"/* ~/.config/nvim
else
  warn "nvim config folder not found"
fi

# Reload tmux config if tmux is running
if command -v tmux &>/dev/null && tmux info &>/dev/null; then
  info "Reloading tmux config"
  tmux source-file ~/.config/tmux/tmux.conf
else
  warn "tmux not running, config not reloaded"
fi

info "✅ Installation complete!"

