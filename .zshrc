# export ZSH="$HOME/.oh-my-zsh"
# ZSH_THEME="fluent-git"
# source $ZSH/oh-my-zsh.sh

export EDITOR=nvim
export PATH=$HOME/bin:$HOME/.local/bin:$PATH:$HOME/scripts/:$HOME/Library/Python/3.11/bin

# Enable SSH completion
export ZSSH_ENABLE_COMPLETION=1
zstyle ':completion:*:ssh:*' use-ssh-no-tty yes
zstyle ':completion:*:scp:*' use-ssh-no-tty yes
zstyle ':completion:*:rsync:*' use-ssh-no-tty yes
# Disable SSH/SCP completion handling by FZF
zstyle ':completion:*:ssh:*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
zstyle ':completion:*:scp:*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-host' ignored-patterns '*(.|:)*' loopback ip6-loopback localhost ip6-localhost broadcasthost
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-domain' ignored-patterns '<->.<->.<->.<->' '^[-[:alnum:]]##(.[-[:alnum:]]##)##' '*@*'
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-ipaddr' ignored-patterns '^(<->.<->.<->.<->|(|::)([[:xdigit:].]##:(#c,2))##(|%*))' '127.0.0.<->' '255.255.255.255' '::1' 'fe80::*'

# Force rebuild completions
rm -f ~/.zcompdump* || true
autoload -Uz compinit
compinit

# SSH Agent configuration
SSH_SOCKET="$HOME/.ssh/ssh-agent-socket"
rm -f "$SSH_SOCKET"
# Start new SSH agent
eval $(ssh-agent -s -a "$SSH_SOCKET") &>/dev/null
export SSH_AUTH_SOCK="$SSH_SOCKET"

# Add SSH keys
find "$HOME/.ssh" -type f -not -name "known_hosts*" -not -name "*.pub" -not -name "config" -not -name "authorized_keys" | while read -r key; do
    if [ -f "$key" ] && ssh-keygen -lf "$key" &>/dev/null; then
        ssh-add -l | grep -q "$(ssh-keygen -lf "$key" | awk '{print $2}')" &>/dev/null || ssh-add "$key" &>/dev/null
    fi
done

# Set up GPG agent
export GPG_TTY=$(tty)
gpgconf --launch gpg-agent &>/dev/null

# ---- go ----
# Golang environment variables
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export PATH=$GOPATH/bin:$GOROOT/bin:$HOME/.local/bin:$PATH:

[[ -f $HOME/.aliases ]] && source $HOME/.aliases

HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000000
SAVEHIST=10000000
setopt APPEND_HISTORY
setopt BANG_HIST                 # Treat the '!' character specially during expansion.
setopt EXTENDED_HISTORY          # Write the history file in the ":start:elapsed;command" format.
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found.
setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space.
setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries in the history file.
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry.
setopt HIST_VERIFY               # Don't execute immediately upon history expansion.
setopt HIST_BEEP                 # Beep when accessing nonexistent history.

# autocompletion using arrow keys (based on history)
bindkey '\e[A' history-search-backward
bindkey '\e[B' history-search-forward

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# DM_STATE=$(podman machine info -f json | jq -r .Host.MachineState)
# if [[ "$DM_STATE" != "Running" ]]; then
#     podman machine start "$(hostname)"
# fi

# ---- FZF -----

# Set up fzf key bindings and fuzzy completion
eval "$(fzf --zsh)"

# --- setup fzf theme ---
fg="#FEFFFF"
bg="#1C1C1E"
bg_highlight="#FFCC00"
purple="#FF2DDE"
blue="#007AFF"
cyan="#32ADE6"
red="#FF3B30"
green="#34C759"

export FZF_DEFAULT_OPTS="--color=fg:${fg},bg:${bg},hl:${purple},fg+:${fg},bg+:${bg_highlight},hl+:${purple},info:${blue},prompt:${cyan},pointer:${cyan},marker:${cyan},spinner:${cyan},header:${cyan}"

# -- Use fd instead of fzf --

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}

source ~/.config/fzf-git.sh

export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always --line-range :500 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo \$'{}"         "$@" ;;
    ssh|scp)      return 1 ;;  # Skip FZF for ssh/scp
    *)            fzf --preview "bat -n --color=always --line-range :500 {}" "$@" ;;
  esac
}

# ----- Bat (better cat) -----

export BAT_THEME="TokyoNight"

eval "$(zoxide init zsh)"

export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"

source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
if [ -f "$HOME/keys/anthropic" ]; then
  export ANTHROPIC_API_KEY=$(cat $HOME/keys/anthropic)
fi
if [ -f "$HOME/keys/openai" ]; then
  export OPENAI_API_KEY=$(cat $HOME/keys/openai)
fi
if [ -f "$HOME/keys/gemini" ]; then
  export GEMINI_API_KEY=$(cat $HOME/keys/gemini)
fi
if [ -f "$HOME/keys/deepseek" ]; then
  export DEEPSEEK_API_KEY=$(cat $HOME/keys/deepseek)
fi


# Added by LM Studio CLI (lms)
export PATH="$PATH:$HOME/.cache/lm-studio/bin"

export KUBECONFIG=$(cat ~/kubeconfig)

# aider specific env vars
export AIDER_ATTRIBUTE_AUTHOR=false
export AIDER_ATTRIBUTE_COMMITTER=false
export AIDER_ATTRIBUTE_COMMIT_MESSAGE_AUTHOR=false
export AIDER_ATTRIBUTE_COMMIT_MESSAGE_COMMITTER=false
export AIDER_AUTO_COMMITS=false 

eval "$(starship init zsh)"
