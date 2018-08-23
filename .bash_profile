alias ls='ls -G'
alias grep='grep -i --color=auto'
export PATH="/usr/local/bin:/usr/local/sbin:/usr/local/mysql/bin:/opt/local/bin:$PATH"
export PS1="\h:\w$ "
export EDITOR=vim

HISTFILESIZE=100000000
HISTSIZE=100000
shopt -s histappend
PROMPT_COMMAND='history -a'

### Source osx bash setup
[[ -f ~/.bash_mac ]] && source ~/.bash_mac

### Source linux bash setup
[[ -f ~/.bash_linux ]] && source ~/.bash_linux

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

[[ -f ~/.bash_profile_jennykortina ]] && source ~/.bash_profile_jennykortina
[[ -f ~/.bash_profile_extensions ]] && source ~/.bash_profile_extensions
