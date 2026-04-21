# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Created by newuser for 5.9
export EDITOR="nvim"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# ========= PATH ================
export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH"

# pnpm 
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"

# pyenv

# PostgreSQL (adjust version number if needed)
export PATH="/usr/lib/postgresql/18/bin:$PATH"

# PATH dedup



# set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Download Zinit, if it is not there yet
if [ ! -d "$ZINIT_HOME" ]; then
	mkdir -p "$(dirname $ZINIT_HOME)"
	git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in powerlevel10k
# ice depth adds arguments to the next zinit command
zinit ice depth=1; 
zinit light romkatv/powerlevel10k

# Core plugins (lazy where possible)
zinit wait lucid for \
    atload"_zsh_autosuggest_start" \
        zsh-users/zsh-autosuggestions \
    blockf atpull'zinit creinstall -q .' \
        zsh-users/zsh-completions \
    Aloxaf/fzf-tab

# OMZ snippets (REMOVE alias-finder)
zinit wait lucid for \
    OMZP::git \
    OMZP::sudo \
    OMZP::docker \
    OMZP::docker-compose \
    OMZP::command-not-found \
    OMZP::alias-finder \
    OMZP::ssh-agent

# Load syntax highlighting LAST (CRITICAL)
zinit ice wait lucid atload'ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)'
zinit light zsh-users/zsh-syntax-highlighting


autoload -Uz compinit
if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi
zinit cdreplay -q


#Load completions
#autoload -Uz compinit
#if [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
#  compinit
#else
#  compinit -C
#fi
#zinit cdreplay -q


# ─── NVM ───────────────────────────────────────────────
# OMZP::nvm above handles lazy loading, but NVM_DIR must be set first
export NVM_DIR="$HOME/.nvm"   # fixed: was $hOME with unclosed quote

declare -a __node_commands=('nvm' 'node' 'npm' 'npx' 'pnpm' 'yarn' 'claude')
function __init_nvm() {
  for i in "${__node_commands[@]}"; do unalias $i 2>/dev/null; done
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  unset __node_commands
  unset -f __init_nvm
}
for i in "${__node_commands[@]}"; do alias $i='__init_nvm && '$i; done





# ─── PYENV ─────────────────────────────────────────────

# ─── DOCKER (WSL) ──────────────────────────────────────
export DOCKER_HOST=unix:///var/run/docker.sock


# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Keybindings
bindkey -e
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# Hisotry
HISTSIZE=1000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
HISTDUP=erase
ZSH_HIGHLIGHT_MAXLENGTH=200
ZSH_AUTOSUGGEST_STRATEGY=(history)
ZSH_AUTOSUGGEST_USE_ASYNC=true
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -color $realpath'
zstyle ':omz:plugins:alias-finder' autoload yes
zstyle ':omz:plugins:alias-finder' cheaper yes
zstyle ':omz:plugins:ssh-agent' lazy yes
zstyle ':omz:plugins:ssh-agent' quiet yes
zstyle ':omz:plugins:ssh-agent' identities droplet_uamnh id_ed25519 id_ed25519_wheelerknight19 id_rsa id_rsa_512 


# Aliases
alias ls='ls --color'
alias cc="claude"
alias cc-auto="claude --dangerously-skip-permissions"
alias pi="pnpm install"
alias pid="pnpm add -D"
alias pd="pnpm dev"
alias pb="pnpm build"
alias ps="pnpm start"
alias pt="pnpm test"
alias pl="pnpm lint"
alias pf="pnpm format"
alias prun="pnpm run"
alias px="pnpm exec"
alias pdlx="pnpm dlx"
alias py="python3"
alias python="python3"
alias pip="pip3"
alias pyact="source .venv/bin/activate"
alias pydeact="deactivate"
alias pynew="python3 -m venv .venv && source .venv/bin/activate && pip install --upgrade pip"
alias vim="nvim"
alias vi="nvim"
alias v="nvim"
alias v.="nvim ."    
alias c="clear"
alias cls="clear"
alias p="pwd"
alias reload="source ~/.zshrc"
alias zshconfig="nvim ~/.zshrc"
alias dotconfig="nvim ~/dotfiles"
alias rmf="rm -rf"
alias cpv="cp -v"
alias mvv="mv -v"
alias mkdirp="mkdir -p"
alias cp="cp -i"
alias mv="mv -i"
alias rm="rm -i"
alias grep="grep --color=auto"
alias lg="lazygit"
alias lzd="lazydocker"


# Aliases for TMUX
alias ta='tmux attach -t'
alias tad='tmux attach -d -t'
alias ts='tmux new -s'
alias tls='tmux list-sessions'
alias tkill='tmux kill-session -t'
alias tkillall='tmux kill-server'


tao() {
  tmux attach -t "$1" || tmux new -s "$1"
}



#eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Shell Integrations
source <(fzf --zsh)

