#!/usr/bin/env bash

set -e

info() { echo -e "\033[34m[INFO]\033[0m $1"; }
error() { echo -e "\033[31m[ERROR]\033[0m $1" >&2; exit 1; }

OS_TYPE="$(uname -s)"

install_mac_bash_deps() {
    info "Updating Homebrew and installing macOS dependencies..."
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi

    brew update
    brew install bash bash-completion fzf zoxide starship
}

install_linux_bash_deps() {
    info "Installing Linux dependencies..."

    if command -v apt-get &>/dev/null; then
        sudo apt-get update -y
        sudo apt-get install -y bash bash-completion fzf zoxide
    elif command -v pacman &>/dev/null; then
        sudo pacman -Sy --needed --noconfirm bash bash-completion fzf zoxide
    else
        error "Unsupported Linux package manager."
    fi

    curl -sS https://starship.rs/install.sh | sh
}

case "$OS_TYPE" in
    Darwin) install_mac_bash_deps ;;
    Linux)  install_linux_bash_deps ;;
    *)      error "Unsupported operating system: $OS_TYPE" ;;
esac

touch "$HOME/.bash_secrets"
touch "$HOME/.bash_history"

# Ask to set as default shell
BASH_PATH="$(command -v bash)"

if [[ -z "$BASH_PATH" ]]; then
    error "Bash binary not found."
fi

if [[ "$SHELL" != "$BASH_PATH" ]]; then
    read -rp "Set Bash ($BASH_PATH) as default shell? [y/N]: " response
    case "$response" in
        [yY][eE][sS]|[yY])
            info "Changing default shell to Bash..."
            
            if ! grep -qF "$BASH_PATH" /etc/shells; then
                info "Adding $BASH_PATH to /etc/shells..."
                echo "$BASH_PATH" | sudo tee -a /etc/shells >/dev/null
            fi
            
            sudo chsh -s "$BASH_PATH" "$USER"
            info "Default shell changed to Bash."
            ;;
        *)
            info "Skipping default shell change."
            ;;
    esac
else
    info "Bash is already the default shell."
fi

info "Bash setup complete!"
