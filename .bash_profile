##################################################
# path adjustments
##################################################
export PATH="/usr/local/bin:/usr/local/sbin:/usr/local/mysql/bin:/opt/local/bin:$PATH"
export PATH="~/.vim/:/usr/local:/usr/local/bin/ruby:$PATH"
export PATH="$HOME/dotfiles/bin:$PATH"

export GOPATH="$HOME/gopath"
export PATH="$GOPATH/bin:$PATH"

##################################################
# aliases and bindings
##################################################
# alias SaveScreen='/System/Library/Frameworks/ScreenSaver.framework/Resources/ScreenSaverEngine.app/Contents/MacOS/ScreenSaverEngine'
alias ag='ag --hidden'
alias dk="docker-compose"
alias flushdns='sudo dscacheutil -flushcache'
alias gg='git grep -n --color --heading --break'
alias grep='grep -i --color=auto'
alias ls='ls -G'
alias pidawk="awk '{print \$2}'"
alias pluginstall='vim +PlugInstall +qall'
alias t="bundle exec rspec --color"
alias tmux="TERM=screen-256color-bce tmux"
alias updatedb='sudo /usr/libexec/locate.updatedb'
alias v='pbpaste | vim -'

export EDITOR=vim
export FZF_DEFAULT_COMMAND='ag -g ""'
export PS1="\h:\w$ "
export TERM="xterm-256color"

HISTFILESIZE=100000000
HISTSIZE=100000
shopt -s histappend
PROMPT_COMMAND='history -a'

# use option delete to delete previous word
bind '"\M-d": backward-kill-word'

##################################################
# pretty bash prompt with git / svn branch name
##################################################
function parse_git_dirty {
    git_version="`git --version | grep -E -o '\d\.\d+'`"
    if (( $(echo "$git_version >= 1.8"|bc -l) )); then 
        nothing_message="nothing to commit, working tree clean";
    else echo "l"; 
        nothing_message="nothing to commit (working directory clean)";
    fi
  # nothing_message=`git --version | ruby -e 'STDIN.readlines[0].match(/(\d+\.\d+)/); puts ($1.to_f >= 1.8) ? "nothing to commit, working tree clean" : "nothing to commit (working directory clean)"'`
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

source_if_exists() {
    source_file_path="$1"
    [[ -f "$source_file_path" ]] && source "$source_file_path"
}

source_if_exists "`brew --prefix`/etc/bash_completion"
source_if_exists "`brew --prefix`/etc/bash_completion.d/rails.bash"
command -v gulp >/dev/null 2>&1  && eval "$(gulp --completion=bash)"

##################################################
# settings not on github
##################################################
source_if_exists "$HOME/.bash_secrets"

##################################################
# ruby
##################################################
export PATH="$HOME/.rbenv/shims:$PATH"
if which rbenv > /dev/null; then eval "$(rbenv init -)"; else echo rbenv not installed; fi
source_if_exists "$HOME/.rbenv/completions/rbenv.bash"

##################################################
# python
##################################################
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then eval "$(pyenv init -)"; fi

##################################################
# javascript
##################################################
export PATH="$HOME/.nodenv/bin:$PATH"
if which nodenv > /dev/null; then eval "$(nodenv init -)"; else echo nodenv not installed; fi

##################################################
# fzf
##################################################
source_if_exists "$HOME/.fzf.bash"
source_if_exists "$HOME/.fzf.conf.bash"

##################################################
# fin
##################################################
export FIN_SSH_USERNAME="andrew_kortina"
export FIN_CODE_HOME="$HOME/code"
fa_bin="/usr/local/bin/fa"
test -h $fa_bin ||  ln -s "$FIN_CODE_HOME/fin-dev/fa" $fa_bin
eval "$(_FA_COMPLETE=source fa)"
