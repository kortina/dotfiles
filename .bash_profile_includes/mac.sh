# kortina mac specific bash profile settings
bind '"\M-d": backward-kill-word'

###
### aliases
###
alias flushdns='sudo dscacheutil -flushcache'
alias SaveScreen='/System/Library/Frameworks/ScreenSaver.framework/Resources/ScreenSaverEngine.app/Contents/MacOS/ScreenSaverEngine'
alias updatedb='sudo /usr/libexec/locate.updatedb'
alias gg='git grep -n --color --heading --break'
alias servejenkins="java -jar /usr/local/Cellar/jenkins/1.477/libexec/jenkins.war"
alias tmux="TERM=screen-256color-bce tmux"

###
### path adjustments
###
export PATH="~/Dropbox/nix/bin:$PATH"
export PATH="~/Dropbox/git/bakpak/bin:$PATH"
export PATH="~/Dropbox/vmvenmo:$PATH"
export PATH="~/.vim/:/usr/local:/usr/local/bin/ruby:$PATH"
export PATH="/usr/local/git/bin:$PATH"
export PATH="/usr/local/jruby-1.6.2/bin:$PATH"
export VENMO_TERMS_TABS_INSTEAD_OF_WINDOWS=1
export VGIT_USERNAME="kortina"
export PATH="~/.rvm/bin/:$PATH"
export PATH="$PATH:~/Dropbox/git/venmo-devops/mac/check/"

export GOPATH="$HOME/gopath"
export PATH="$GOPATH/bin:$PATH"

# Setting PATH for MacPython 2.5
PATH="/Library/Frameworks/Python.framework/Versions/Current/bin:${PATH}"
export PATH

source $HOME/.rvm/scripts/rvm

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

test -r /sw/bin/init.sh && . /sw/bin/init.sh

if [ -f `brew --prefix`/etc/bash_completion ]; then
. `brew --prefix`/etc/bash_completion
fi
