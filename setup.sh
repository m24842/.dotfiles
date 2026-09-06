#!/usr/bin/env bash

set -e

info() { echo -e "\033[34m[INFO]\033[0m $1"; }
error() { echo -e "\033[31m[ERROR]\033[0m $1" >&2; exit 1; }

OS_TYPE="$(uname -s)"

install_mac_tools() {
    info "Installing general tools for macOS..."
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi

    brew update
    brew install git gh curl unzip ripgrep fd llvm ffmpeg \
                 android-commandlinetools nvm pyenv miniconda
}

install_linux_tools() {
    info "Installing general tools for Linux..."

    if command -v apt-get &>/dev/null; then
        sudo apt-get update -y
        sudo apt-get install -y git gh curl unzip build-essential ripgrep fd-find \
                                llvm ffmpeg libssl-dev zlib1g-dev libbz2-dev \
                                libreadline-dev libsqlite3-dev libffi-dev
    elif command -v pacman &>/dev/null; then
        sudo pacman -Sy --needed --noconfirm git gh curl unzip base-devel ripgrep fd \
                                           llvm ffmpeg openssl zlib \
                                           bzip2 readline sqlite libffi
    else
        error "Unsupported Linux package manager. Please install dependencies manually."
    fi

    # Pyenv
    export PYENV_ROOT="$HOME/.pyenv"
    if [[ ! -d "$PYENV_ROOT" ]]; then
        info "Installing Pyenv..."
        curl -fsSL https://pyenv.run | bash
    fi

    # Miniconda
    if [[ ! -d "$HOME/miniconda3" ]]; then
        info "Installing Miniconda..."
        mkdir -p "$HOME/miniconda3"
        curl -fsSL https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o "$HOME/miniconda3/miniconda.sh"
        bash "$HOME/miniconda3/miniconda.sh" -b -u -p "$HOME/miniconda3"
        rm -rf "$HOME/miniconda3/miniconda.sh"
    fi

    # NVM
    export NVM_DIR="$HOME/.config/nvm"
    if [[ ! -d "$NVM_DIR" ]]; then
        info "Installing NVM..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    fi
}

case "$OS_TYPE" in
    Darwin) install_mac_tools ;;
    Linux)  install_linux_tools ;;
    *)      error "Unsupported operating system: $OS_TYPE" ;;
esac

info "General tools setup complete!"

# Run additional setup scripts
prompt_and_run() {
    local script_name="$1"
    local description="$2"
    local script_path="./${script_name}"

    if [[ -f "$script_path" ]]; then
        read -rp "Run ${description} (${script_name})? [y/N]: " response
        case "$response" in
            [yY][eE][sS]|[yY])
                info "Executing ${script_name}..."
                bash "$script_path"
                ;;
            *)
                info "Skipping ${script_name}."
                ;;
        esac
    else
        info "Skipping ${script_name} (File not found)."
    fi
}

echo "--------------------------------------------------"

PARENT_DIR="$(dirname "$0")"

prompt_and_run "$PARENT_DIR/nvim/setup.sh" "Neovim Setup"
prompt_and_run "$PARENT_DIR/zsh/setup.sh"  "Zsh Setup"
prompt_and_run "$PARENT_DIR/tmux/setup.sh" "Tmux Setup"
prompt_and_run "$PARENT_DIR/bash/setup.sh" "Bash Setup"

info "All requested setup scripts finished!"
