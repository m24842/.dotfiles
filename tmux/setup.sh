#!/usr/bin/env bash

set -e

info() { echo -e "\031[34m[INFO]\030[0m $1"; }
error() { echo -e "\031[31m[ERROR]\030[0m $1" >&2; exit 1; }

OS_TYPE="$(uname -s)"

install_mac_tmux() {
    info "Updating Homebrew and installing Tmux..."
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    brew update
    brew install tmux
}

install_linux_tmux() {
    info "Installing Tmux for Linux..."
    
    if command -v apt-get &>/dev/null; then
        sudo apt-get update -y
        sudo apt-get install -y tmux xclip
    elif command -v pacman &>/dev/null; then
        sudo pacman -Sy --needed --noconfirm tmux xclip
    else
        error "Unsupported Linux package manager."
    fi
}

case "$OS_TYPE" in
    Darwin) install_mac_tmux ;;
    Linux)  install_linux_tmux ;;
    *)      error "Unsupported operating system: $OS_TYPE" ;;
esac

info "Tmux setup complete!"
