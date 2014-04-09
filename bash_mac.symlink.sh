# boxen env.sh
test -f /opt/boxen/env.sh && source /opt/boxen/env.sh

# kortina mac specific bash profile settings
bind '"\M-d": backward-kill-word'

##################################################
# aliases
##################################################
alias flushdns='sudo dscacheutil -flushcache'
alias SaveScreen='/System/Library/Frameworks/ScreenSaver.framework/Resources/ScreenSaverEngine.app/Contents/MacOS/ScreenSaverEngine'
alias updatedb='sudo /usr/libexec/locate.updatedb'
alias gg='git grep -n --color --heading --break'
alias tmux="TERM=screen-256color-bce tmux"
export TERM="xterm-256color"


##################################################
# path adjustments
##################################################
# export PATH="~/Dropbox/nix/bin:$PATH"
export PATH="~/Dropbox/git/bakpak/bin:$PATH"
export PATH="~/.vim/:/usr/local:/usr/local/bin/ruby:$PATH"

export GOPATH="$HOME/gopath"
export PATH="$GOPATH/bin:$PATH"

# Setting PATH for MacPython 2.5
PATH="/Library/Frameworks/Python.framework/Versions/Current/bin:${PATH}"
export PATH


##################################################
# pretty bash prompt with git / svn branch name
##################################################
function parse_git_dirty {
  nothing_message=`git --version | ruby -e 'STDIN.readlines[0].match(/(\d+\.\d+)/); puts ($1.to_f >= 1.8) ? "nothing to commit, working directory clean" : "nothing to commit (working directory clean)"'`
  [[ $(git status 2> /dev/null | tail -n1) != "$nothing_message" ]] && echo "*"
}
function parse_git_branch {
  git branch 2> /dev/null | sed -e "/^[^*]/d" -e "s/* \(.*\)/(\1$(parse_git_dirty))/"
}
function parse_svn_branch {
        svn info 2> /dev/null | grep URL | sed -e "s/.*\/\(.*\)$/(\1)/"
}
PS1="\n\
\[\033[0;32m\]\u$DIM \[\033[0;37m\]@ \[\033[0;33m\]\h 
\[\033[0;35m\]\$PWD \[\033[0;37m\]\$(parse_git_branch 2> /dev/null)\$(parse_svn_branch 2> /dev/null)$ " && export PS1


##################################################
# bash completion
##################################################
if [ -f `brew --prefix`/etc/bash_completion ]; then
. `brew --prefix`/etc/bash_completion
fi
