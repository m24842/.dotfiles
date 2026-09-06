#!/usr/bin/env bash

set -e

info() { echo -e "\031[34m[INFO]\030[0m $1"; }
error() { echo -e "\031[31m[ERROR]\030[0m $1" >&2; exit 1; }

OS_TYPE="$(uname -s)"

install_mac_zsh() {
    info "Updating Homebrew and installing Zsh dependencies..."
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    brew update
    brew install zsh fzf zoxide
}

install_linux_zsh() {
    info "Installing Zsh dependencies for Linux..."
    
    if command -v apt-get &>/dev/null; then
        sudo apt-get update -y
        sudo apt-get install -y zsh fzf zoxide
    elif command -v pacman &>/dev/null; then
        sudo pacman -Sy --needed --noconfirm zsh fzf zoxide
    else
        error "Unsupported Linux package manager."
    fi
}

case "$OS_TYPE" in
    Darwin) install_mac_zsh ;;
    Linux)  install_linux_zsh ;;
    *)      error "Unsupported operating system: $OS_TYPE" ;;
esac


# Ask to set as default shell
ZSH_PATH="$(command -v zsh)"

if [[ -z "$ZSH_PATH" ]]; then
    error "Zsh binary not found."
fi

if [[ "$SHELL" != "$ZSH_PATH" ]]; then
    read -rp "Set Zsh ($ZSH_PATH) as default shell? [y/N]: " response
    case "$response" in
        [yY][eE][sS]|[yY])
            info "Changing default shell to Zsh..."
            
            if ! grep -qF "$ZSH_PATH" /etc/shells; then
                info "Adding $ZSH_PATH to /etc/shells..."
                echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
            fi
            
            sudo chsh -s "$ZSH_PATH" "$USER"
            info "Default shell changed to Zsh."
            ;;
        *)
            info "Skipping default shell change."
            ;;
    esac
else
    info "Zsh is already the default shell."
fi

info "Zsh setup complete!"
