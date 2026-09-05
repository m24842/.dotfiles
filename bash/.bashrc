# ===============================
# ==== System Configurations ====
# ===============================

# Load secrets
[[ -f "$HOME/.bash_secrets" ]] && source "$HOME/.bash_secrets"
[[ -f "$HOME/.zsh_secrets" ]] && source "$HOME/.zsh_secrets"

# Base PATH setup
if [[ "$OSTYPE" == "darwin"* ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    export ANDROID_HOME=/opt/homebrew/share/android-commandlinetools
    export PATH="$PATH:$ANDROID_HOME/platform-tools:/opt/homebrew/opt/llvm/bin"
    export PKG_CONFIG_PATH="/opt/homebrew/opt/ffmpeg/lib/pkgconfig:$PKG_CONFIG_PATH"
    export LDFLAGS="-L/opt/homebrew/opt/llvm/lib"
    export CPPFLAGS="-I/opt/homebrew/opt/llvm/include"
    export PYTORCH_ENABLE_MPS_FALLBACK=1
    if ! command -v tac >/dev/null 2>&1; then
        tac() { tail -r; }
        export -f tac
    fi
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    export PATH="$HOME/bin:$HOME/.local/bin:$HOME/.cargo/bin:$HOME/.fzf/bin:$PATH"
fi

# Lazy NVM
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
nvm() {
    unset -f nvm node npm npx
    if [[ "$OSTYPE" == "darwin"* ]]; then
        [[ -s "/opt/homebrew/opt/nvm/nvm.sh" ]] && \. "/opt/homebrew/opt/nvm/nvm.sh"
    else
        [[ -s "$NVM_DIR/nvm.sh" ]] && \. "$NVM_DIR/nvm.sh"
    fi
    nvm "$@"
}
node() { nvm; node "$@"; }
npm()  { nvm; npm "$@"; }
npx()  { nvm; npx "$@"; }

# Lazy Pyenv
export PYENV_ROOT="$HOME/.pyenv"
if [[ -d "$PYENV_ROOT/bin" ]]; then
    export PATH="$PYENV_ROOT/bin:$PATH"
    pyenv() {
        unset -f pyenv
        eval "$(command pyenv init -)"
        eval "$(command pyenv virtualenv-init -)"
        pyenv "$@"
    }
fi

# Lazy Conda
conda() {
    unset -f conda
    if [[ "$OSTYPE" == "darwin"* ]]; then
        [[ -f "/opt/anaconda3/etc/profile.d/conda.sh" ]] && . "/opt/anaconda3/etc/profile.d/conda.sh"
    else
        for conda_dir in "$HOME/anaconda3" "$HOME/miniconda3" "/opt/anaconda3"; do
            if [[ -f "$conda_dir/etc/profile.d/conda.sh" ]]; then
                . "$conda_dir/etc/profile.d/conda.sh"
                break
            fi
        done
    fi
    conda "$@"
}

# Venv Hook
venv_hook() {
    if [[ -f ".venv/bin/activate" ]]; then
        if [[ "$VIRTUAL_ENV" != "$PWD/.venv" ]]; then
            source .venv/bin/activate
        fi
    elif [[ -n "$VIRTUAL_ENV" ]]; then
        deactivate 2>/dev/null
    fi
}
PROMPT_COMMAND="venv_hook;${PROMPT_COMMAND:-}"

# Huggingface configuration
export TOKENIZERS_PARALLELISM=false

# ==================================
# ===== Cmd Line Configurations ====
# ==================================

export LANG=en_US.UTF-8

# History configuration
HISTSIZE=5000
HISTFILESIZE=5000
HISTFILE=~/.bash_history
HISTCONTROL=ignoreboth:erasedups
shopt -s histappend

# Bash completions
if ! shopt -oq posix; then
    bind 'set completion-ignore-case on'
    bind 'set show-all-if-ambiguous on'

    if [[ "$OSTYPE" == "darwin"* && -f /opt/homebrew/etc/profile.d/bash_completion.sh ]]; then
        . /opt/homebrew/etc/profile.d/bash_completion.sh
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [[ -f /usr/share/bash-completion/bash_completion ]]; then
            . /usr/share/bash-completion/bash_completion
        elif [[ -f /etc/bash_completion ]]; then
            . /etc/bash_completion
        fi
    fi
fi

# BLE.sh initialize
BLE_DIR="$HOME/.local/share/blesh"
if [[ -f "$BLE_DIR/ble.sh" && ! ${BLE_VERSION-} ]]; then
    source "$BLE_DIR/ble.sh" --noattach
fi

# FZF tab completion
FZF_TAB_DIR="$HOME/.fzf-tab-completion"
if [[ -f "$FZF_TAB_DIR/bash/fzf-bash-completion.sh" ]]; then
    export FZF_COMPLETION_OPTS="--color=info:bold:yellow --no-multi"
    source "$FZF_TAB_DIR/bash/fzf-bash-completion.sh"

    if [[ ${BLE_VERSION-} ]]; then
        ble-bind -m auto_complete -c TAB fzf_bash_completion
        ble-bind -m menu_complete -c TAB fzf_bash_completion
    else
        bind -x '"\t": fzf_bash_completion'
    fi
    shopt -s no_empty_cmd_completion
fi

# Attach BLE.sh
if [[ ${BLE_VERSION-} ]]; then
    bleopt exec_errexit_mark=''
    # General text
    ble-face auto_complete='fg=#6e6a86'
    ble-face syntax_default='none'
    ble-face syntax_error='none'
    ble-face syntax_comment='none'
    ble-face syntax_varname='none'
    ble-face argument_option='none'
    # File text
    ble-face filename_directory='none'
    ble-face filename_link='none'
    ble-face filename_other='none'
    ble-face filename_ls_colors='none'
    # Command text
    ble-face command_builtin='fg=#31748f,bold'
    ble-face command_alias='fg=#31748f,bold'
    ble-face command_function='fg=#31748f,bold'
    ble-face command_file='fg=#31748f,bold'
fi

# Cursor style
PROMPT_COMMAND='echo -ne "\e[6 q"; '"$PROMPT_COMMAND"

# Starship prompt (Pure prompt theme)
if ! command -v starship &> /dev/null; then
    curl -sS https://starship.rs/install.sh | sh
fi
eval "$(starship init bash)"

# FZF configuration
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Aliases
alias ls='ls --color=auto'
alias nv='nvim'
alias c='clear'
alias tx='tmux'

# Shell integrations
eval "$(zoxide init --cmd cd bash)"

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

[[ ${BLE_VERSION-} ]] && ble-attach -d
