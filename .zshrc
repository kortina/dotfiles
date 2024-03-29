# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# theme
source $HOME/dotfiles/themes/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit $HOME/.p10k.zsh.
[[ ! -f $HOME/.p10k.zsh ]] || source $HOME/.p10k.zsh
##################################################
# add precommit status to prompt
# to warn if a .pre-commit-config.yaml file exists
# but is not installed to git
##################################################
function prompt_kortina_precommit_status() {
  if [ -e .pre-commit-config.yaml ] && [ ! -e "`git rev-parse --git-path hooks`/pre-commit" ]; then
    p10k segment -s WARM -f yellow -i "" -t "pre-commit install"
  fi
}
old=($POWERLEVEL9K_LEFT_PROMPT_ELEMENTS)
POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=()
for v in $old ; do
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS+=($v) ;
  [[ "$v" == "vcs" ]] && POWERLEVEL9K_LEFT_PROMPT_ELEMENTS+=("kortina_precommit_status")
done;
##################################################

test -e /opt/homebrew/bin/brew && eval "$(/opt/homebrew/bin/brew shellenv)"
# syntax highlight commands
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

##################################################
# completions
##################################################
source $HOME/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
fpath=($HOME/.zsh/completion $HOME/.zsh/zsh-completions $fpath)

# ssh host completions
# https://serverfault.com/a/170481
h=()
if [[ -r ~/.ssh/config ]]; then
  h=($h ${${${(@M)${(f)"$(cat ~/.ssh/config)"}:#Host *}#Host }:#*[*?]*})
fi
# if [[ -r ~/.ssh/known_hosts ]]; then
#   h=($h ${${${(f)"$(cat ~/.ssh/known_hosts{,2} || true)"}%%\ *}%%,*}) 2>/dev/null
# fi
if [[ $#h -gt 0 ]]; then
  zstyle ':completion:*:ssh:*' hosts $h
  zstyle ':completion:*:slogin:*' hosts $h
  zstyle ':completion:*:ssh:*' ignored-patterns '_*'
  zstyle ':completion:*:slogin:*' ignored-patterns '_*'
fi

autoload -Uz compinit
compinit -i
setopt auto_list
unsetopt always_last_prompt # important! https://github.com/pallets/click/issues/1667
setopt no_menu_complete
setopt no_auto_menu
setopt magicequalsubst

##################################################
# key-bindings
##################################################
source $HOME/.profile
# vim mode
bindkey -v
export KEYTIMEOUT=1

# up and down to search history with prefix from cursor
bindkey "^[[A" history-beginning-search-backward
bindkey "^[[B" history-beginning-search-forward

# alt+backspace delete word (needed to add after setting vim mode)
bindkey '^[^?' backward-kill-word
# alt arrows to move by word (needed to add after setting vim mode)
bindkey "^[f" forward-word
bindkey "^[b" backward-word

# expand history variables on space
bindkey " " magic-space

# export WORDCHARS='*?_-.[]~=/&;!#$%^(){}<>' # default
export   WORDCHARS='*?_-[]~=&;!#$%^(){}'

# fzf
[ -f $HOME/.fzf.zsh ] && source $HOME/.fzf.zsh

# allow # characters as comments on command line
setopt interactivecomments

##################################################
# history
##################################################
HISTSIZE=500000             # How many lines of history to keep in memory
HISTFILE=$HOME/.zsh_history     # Where to save history to disk
SAVEHIST=500000             # Number of history entries to save to disk
#HISTDUP=erase              # Erase duplicates in the history file
setopt    appendhistory     # Append history to the history file (no overwriting)
setopt    sharehistory      # Share history across terminals
setopt    incappendhistory  # Immediately append to the history file, not just when a term is killed
alias history="history 1"

##################################################
# fin
##################################################
test -e "$HOME/code/fin-dev" && eval "$(_FA_COMPLETE=zsh_source fa)"

##################################################
# sq
##################################################
if [ -d "$HOME/src/sq" ] ; then 
  export PATH="$PATH:$HOME/src/sq"
  eval "$(_SQ_COMPLETE=zsh_source sq)"
fi

##################################################
# ai
##################################################
if [ -d "$HOME/src/ai-python" ] ; then 
  export PATH="$PATH:$HOME/src/ai-python"
  eval "$(_AI_COMPLETE=zsh_source ai)"
  # I also alias to just `a`  and `c`;)
  alias a="ai"
  alias c="ai --rc"
fi

##################################################
# fzf
##################################################
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh