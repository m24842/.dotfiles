#!/usr/bin/env bash

set -e

info() { echo -e "\031[34m[INFO]\030[0m $1"; }
error() { echo -e "\031[31m[ERROR]\030[0m $1" >&2; exit 1; }

OS_TYPE="$(uname -s)"

install_mac_nvim() {
    info "Updating Homebrew and installing Neovim dependencies..."
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi

    brew update
    brew install neovim git gh ripgrep fd nvm node npm gcc llvm

    export NVM_DIR="$HOME/.nvm"
    [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"

    npm install -g --allow-scripts=tree-sitter-cli tree-sitter-cli
}

install_linux_nvim() {
    info "Installing Neovim dependencies for Linux..."
    
    if command -v apt-get &>/dev/null; then
        sudo apt-get update -y
        sudo apt-get install -y xclip git gh build-essential ripgrep fd-find nodejs llvm
        sudo snap install nvim
    elif command -v pacman &>/dev/null; then
        sudo pacman -Sy --needed --noconfirm xclip neovim git gh base-devel ripgrep fd nodejs llvm
    else
        error "Unsupported Linux package manager."
    fi

    export NVM_DIR="$HOME/.config/nvm"
    if [ ! -d "$NVM_DIR" ]; then
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    fi

    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install node
    nvm install-latest-npm
    npm install -g --allow-scripts=tree-sitter-cli tree-sitter-cli
}

git submodule update --init --recursive
git submodule update --remote --merge

case "$OS_TYPE" in
    Darwin) install_mac_nvim ;;
    Linux)  install_linux_nvim ;;
    *)      error "Unsupported operating system: $OS_TYPE" ;;
esac

info "Neovim setup complete!"
