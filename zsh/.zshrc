# ===============================
# ==== System Configurations ====
# ===============================

# Load secrets
[[ -f "$HOME/.zsh_secrets" ]] && source "$HOME/.zsh_secrets"

# OS specific configurations
if [[ "$OSTYPE" == "darwin"* ]]; then
    # Mac OS

    # Homebrew setup
    eval "$(/opt/homebrew/bin/brew shellenv)"
    fpath+=("$HOMEBREW_PREFIX/share/zsh/site-functions")

    # Android SDK configuration
    export ANDROID_HOME=/opt/homebrew/share/android-commandlinetools
    export PATH=$PATH:$ANDROID_HOME/platform-tools

    # FFmpeg config path
    export PKG_CONFIG_PATH="/opt/homebrew/opt/ffmpeg/lib/pkgconfig:$PKG_CONFIG_PATH"

    # Compiler flags for LLVM
    export PATH="/opt/homebrew/opt/llvm/bin:$PATH"
    export LDFLAGS="-L/opt/homebrew/opt/llvm/lib"
    export CPPFLAGS="-I/opt/homebrew/opt/llvm/include"

    # Conda initialization
    if [ -f "/opt/anaconda3/bin/conda" ]; then
        eval "$('/opt/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
    else
        [[ -f "/opt/anaconda3/etc/profile.d/conda.sh" ]] && . "/opt/anaconda3/etc/profile.d/conda.sh"
    fi

    # PyTorch configuration
    export PYTORCH_ENABLE_MPS_FALLBACK=1

elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    
    # Bin path
    export PATH="$HOME/bin:$PATH"
    export PATH="$HOME/.local/bin:$PATH"

    # Cargo
    export PATH="$HOME/.cargo/bin:$PATH"

    # FZF
    export PATH="$HOME/.fzf/bin:$PATH"

    # TensorRT
    export TENSORRT_ROOT=$HOME/TensorRT-8.6.1.6
    export LD_LIBRARY_PATH=$TENSORRT_ROOT/lib:$LD_LIBRARY_PATH

    # cuDNN
    export CUDNN_DIR=$HOME/cudnn-linux-x86_64-8.9.7.29_cuda11-archive
    export LD_LIBRARY_PATH=$CUDNN_DIR/lib:$LD_LIBRARY_PATH

    # MMDeploy SDK
    export MMDEPLOY_DIR=$HOME/mmdeploy/build/install
    export LD_LIBRARY_PATH=$MMDEPLOY_DIR/lib:$LD_LIBRARY_PATH

    # Conda initialization
    for conda_dir in "$HOME/anaconda3" "$HOME/miniconda3" "/opt/anaconda3"; do
        if [ -f "$conda_dir/bin/conda" ]; then
            eval "$("$conda_dir/bin/conda" 'shell.zsh' 'hook' 2> /dev/null)"
            break
        elif [ -f "$conda_dir/etc/profile.d/conda.sh" ]; then
            . "$conda_dir/etc/profile.d/conda.sh"
            break
        fi
    done

fi

# Shared configurations

# Venv activation
autoload -U add-zsh-hook
venv_hook() {
    if [[ -n "$VIRTUAL_ENV" && -f ".venv/bin/activate" ]]; then
        if [[ "$VIRTUAL_ENV" != "$PWD/.venv" ]]; then
            deactivate 2>/dev/null
        fi
    fi
    if [[ -f ".venv/bin/activate" ]]; then
        if [[ "$VIRTUAL_ENV" != "$PWD/.venv" ]]; then
            source .venv/bin/activate
        fi
    fi
}
add-zsh-hook chpwd venv_hook
venv_hook

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
zinit ice compile'(pure|async).zsh' pick'async.zsh' src'pure.zsh'
zinit light sindresorhus/pure
autoload -U promptinit; promptinit
prompt pure
PURE_GIT_PULL=0
zstyle :prompt:pure:title show no
zstyle :prompt:pure:git:stash show yes
zstyle :prompt:pure:git:stash color white
zstyle :prompt:pure:git:arrow color white
zstyle :prompt:pure:git:dirty color red
zstyle :prompt:pure:prompt:error color red
zstyle :prompt:pure:prompt:success color white

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
