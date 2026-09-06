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
    export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
    export PYTORCH_ENABLE_MPS_FALLBACK=1
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    export PATH="$HOME/bin:$HOME/.local/bin:$HOME/.cargo/bin:$HOME/.fzf/bin:$PATH"
    export NVM_DIR="$HOME/.config/nvm"
fi

# Lazy NVM
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

# Hugginface configuration
export TOKENIZERS_PARALLELISM=false

# ==================================
# ===== Cmd Line Configurations ====
# ==================================

export LANG=en_US.UTF-8

# History
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
setopt inc_append_history
unsetopt share_history
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_find_no_dups
setopt hist_ignore_space

# Initialize completions
autoload -Uz compinit && compinit

# Zinit configuration
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git/zinit.zsh"

# Pure prompt
PURE_GIT_PULL=0
zstyle :prompt:pure:title show no
zstyle :prompt:pure:git:stash show yes
zstyle :prompt:pure:git:stash color white
zstyle :prompt:pure:git:arrow color white
zstyle :prompt:pure:git:dirty color red
zstyle :prompt:pure:prompt:error color red
zstyle :prompt:pure:prompt:success color white
zinit ice compile'(pure|async).zsh' pick'async.zsh' src'pure.zsh'
zinit light sindresorhus/pure

# Other plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab
zinit snippet OMZP::command-not-found

# Completions
zinit cdreplay -q
zstyle ':completion:*' menu no
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:*' fzf-flags '--no-multi' '--color=info:bold:yellow'

# FZF configuration
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Alias
alias ls='ls --color'
alias nv='nvim'
alias c='clear'
alias tx='tmux'

# Shell integrations
source <(fzf --zsh)
eval "$(zoxide init --cmd cd zsh)"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
