# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source $HOME/dotfiles/themes/powerlevel10k/powerlevel10k.zsh-theme
# To customize prompt, run `p10k configure` or edit $HOME/.p10k.zsh.
[[ ! -f $HOME/.p10k.zsh ]] || source $HOME/.p10k.zsh



##################################################
# completions
##################################################
fpath=($HOME/.zsh/completion $HOME/.zsh/zsh-completions $fpath)

autoload -Uz compinit
compinit -i
source $HOME/.profile

[ -f $HOME/.fzf.zsh ] && source $HOME/.fzf.zsh
# up and down to search history with prefix from cursor
bindkey "^[[A" history-beginning-search-backward
bindkey "^[[B" history-beginning-search-forward
bindkey " " magic-space # do history expansion on space

# by default: export WORDCHARS='*?_-.[]~=/&;!#$%^(){}<>'
# we take out the slash, period, angle brackets, dash here.
export WORDCHARS='*?_-[]~=&;!#$%^(){}'
HISTSIZE=500000             # How many lines of history to keep in memory
HISTFILE=$HOME/.zsh_history     # Where to save history to disk
SAVEHIST=500000             # Number of history entries to save to disk
#HISTDUP=erase              # Erase duplicates in the history file
setopt    appendhistory     # Append history to the history file (no overwriting)
setopt    sharehistory      # Share history across terminals
setopt    incappendhistory  # Immediately append to the history file, not just when a term is killed

##################################################
# fin
##################################################
eval "$(_FA_COMPLETE=source_zsh fa)"

##################################################
# sq
##################################################
export PATH="$PATH:$HOME/src/sq"
eval "$(_SQ_COMPLETE=source_zsh sq)"


##################################################
# more zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh