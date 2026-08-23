#!/usr/bin/env bash

set -euo pipefail

# Print styled messages
info()  { echo -e "\033[1;34m[INFO]\033[0m $*"; }
warn()  { echo -e "\033[1;33m[WARN]\033[0m $*"; }
error() { echo -e "\033[1;31m[ERROR]\033[0m $*"; exit 1; }

# Packages required:
# - git, curl, unzip, tar, gzip, make, gcc/clang
# - ripgrep, fd
# - neovim, tmux, zsh
# - nodejs, npm

OS_TYPE="$(uname -s)"

if [[ "$OS_TYPE" == "Linux" ]] || [[ "$OS_TYPE" == "Darwin" ]]; then
    info "Requesting administrator privileges..."
    sudo -v

    while true; do
        sudo -n true
        sleep 60
        kill -0 "$$" 2>/dev/null || exit
    done 2>/dev/null &
    SUDO_KEEPALIVE_PID=$!
    
    trap 'kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true' EXIT
fi

install_mac() {
    info "Installing for MacOS"
    if ! command -v brew &>/dev/null; then
        info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    fi

    info "Updating Homebrew and installing dependencies..."
    brew update
    brew install -y neovim tmux zsh git gh curl unzip ripgrep fd node npm gcc \
                 fzf zoxide llvm ffmpeg android-commandlinetools

    export NVM_DIR="$HOME/.nvm"
    [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"
    [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
}

install_linux() {
    info "Installing for Linux."
    
    if command -v apt-get &>/dev/null; then
        info "Using APT package manager..."
        sudo apt-get update -y
        sudo apt-get install -y xclip tmux zsh git gh curl unzip build-essential \
                                ripgrep fd-find nodejs fzf zoxide llvm ffmpeg
        sudo snap install nvim
    elif command -v dnf &>/dev/null; then
        info "Using DNF package manager..."
        sudo dnf check-update || true
        sudo dnf install -y xclip neovim tmux zsh git gh curl unzip gcc gcc-c++ make \
                            ripgrep fd-find nodejs fzf zoxide llvm ffmpeg
    elif command -v pacman &>/dev/null; then
        info "Using Pacman package manager..."
        sudo pacman -Sy --needed --noconfirm xclip neovim tmux zsh git gh curl unzip base-devel \
                                             ripgrep fd nodejs fzf zoxide llvm ffmpeg
    elif command -v zypper &>/dev/null; then
        info "Using Zypper package manager..."
        sudo zypper refresh
        sudo zypper install -y xclip neovim tmux zsh git gh url unzip gcc gcc-c++ make \
                               ripgrep fd nodejs fzf zoxide llvm ffmpeg
    else
        error "Unsupported Linux package manager. Please install dependencies manually."
    fi

    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.7/install.sh | bash
    export NVM_DIR="$HOME/.config/nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
}

install_misc() {
    info "Installing general packages."
    nvm install node
    nvm install-latest-npm
    npm install -g --allow-scripts=tree-sitter-cli tree-sitter-cli
}

# 0. Fetch Submodules
git submodule update --init --recursive
git submodule update --remote --merge
cd ~

# 1. Install System Dependencies
case "$OS_TYPE" in
    Darwin)
        install_mac
        ;;
    Linux)
        install_linux
        ;;
    *)
        error "Unsupported operating system: $OS_TYPE"
        ;;
esac
install_misc

# 2. Set Zsh as Default Shell
ZSH_PATH="$(command -v zsh)"

if [[ -z "$ZSH_PATH" ]]; then
    error "Zsh binary not found after installation."
fi

if [[ "$SHELL" != "$ZSH_PATH" ]]; then
    info "Changing default shell to Zsh ($ZSH_PATH)..."
    
    # Ensure Zsh path is listed in /etc/shells before invoking chsh
    if ! grep -qF "$ZSH_PATH" /etc/shells; then
        info "Adding $ZSH_PATH to /etc/shells..."
        echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
    fi
    
    sudo chsh -s "$ZSH_PATH" "$USER"
    info "Default shell changed to Zsh."
else
    info "Zsh is already set as the default shell."
fi

info "Setup complete!"
