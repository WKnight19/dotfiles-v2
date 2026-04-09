# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Created by newuser for 5.9
export PATH="$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH"
export PATH="/usr/local/bin:/usr/bin:/bin:$PATH"
export EDITOR="nvim"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"


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
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Add in zsh plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Add in snippets
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::docker
zinit snippet OMZP::docker-compose
zinit snippet OMZP::tmux
zinit snippet OMZP::alias-finder
zinit snippet OMZP::command-not-found
zinit snippet OMZP::ssh-agent



#Load completions
autoload -U compinit && compinit

zinit cdreplay -q


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
zstyle ':omz:plugins:ssh-agent' identities DO_WheelerDesktop WheelerDesktop@GordonPalmer devops id_ed25519 id_rsa known_hosts wheeler_linux_wbknight1_id_ed25519


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

# Shell integrations
source <(fzf --zsh)
