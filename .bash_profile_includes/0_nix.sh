alias ls='ls -G'
alias grep='grep -i --color=auto'
export PATH="/usr/local/bin:/usr/local/sbin:/usr/local/mysql/bin:/opt/local/bin:$PATH"
export PS1="\h:\w$ "
export EDITOR=vim

HISTFILESIZE=100000000
HISTSIZE=100000
shopt -s histappend
PROMPT_COMMAND='history -a'
