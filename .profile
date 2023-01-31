# This file can be sourced in either
# bash or zsh.
##################################################
# path adjustments
##################################################
export PATH="/usr/local/bin:/usr/local/sbin:/usr/local/mysql/bin:/opt/local/bin:$PATH"
export PATH="~/.vim/:/usr/local:/usr/local/bin/ruby:$PATH"
export PATH="$HOME/dotfiles/bin:$HOME/dotfiles/av_transcribe:$PATH"

export GOPATH="$HOME/gopath"
export PATH="$GOPATH/bin:$PATH"

##################################################
# aliases and bindings
##################################################
# alias SaveScreen='/System/Library/Frameworks/ScreenSaver.framework/Resources/ScreenSaverEngine.app/Contents/MacOS/ScreenSaverEngine'
# alias ag='ag --hidden'
alias g='rg --hidden'
alias gf='rg . -lg' # find files with names matching glob, eg: gf "*.md"
alias diff='PAGER=cat git diff --no-index'
alias dk="docker-compose"
alias flushdns='sudo dscacheutil -flushcache'
alias gg='git grep -n --color --heading --break'
alias grep='grep -i --color=auto'
alias ls='ls -G'
alias pidawk="awk '{print \$2}'"
alias pluginstall='vim +PlugInstall +qall'
alias renew_dchp_lease='ipconfig getpacket en0 2>&1 > /tmp/before; echo "add State:/Network/Interface/en0/RefreshConfiguration temporary" | sudo scutil; ipconfig getpacket en0 2>&1 > /tmp/after; diff before after;'
alias t="bundle exec rspec --color"
alias tmux="TERM=screen-256color-bce tmux"
alias updatedb='sudo /usr/libexec/locate.updatedb'
alias v='pbpaste | vim -'

function f() {
    rg --hidden --files | rg "$1"
}

export EDITOR=vim
# export FZF_DEFAULT_COMMAND='ag -g ""'
export FZF_DEFAULT_COMMAND='rg --files --hidden' # --no-ignore-vcs
export TERM="xterm-256color"
HISTFILESIZE=100000000
HISTSIZE=100000
PROMPT_COMMAND='history -a'

##################################################
# functions
##################################################
source_if_exists() {
    source_file_path="$1"
    [[ -f "$source_file_path" ]] && source "$source_file_path"
}
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

##################################################
# settings not on github
##################################################
source_if_exists "$HOME/.bash_secrets"

##################################################
# ruby
##################################################
export PATH="$HOME/.rbenv/shims:$PATH"
if which rbenv > /dev/null; then rbenv_cmd="rbenv" ; else rbenv_cmd="/opt/homebrew/bin/rbenv" ; fi
# ak added &
if which rbenv > /dev/null || test -e $rbenv_cmd ; then eval "$($rbenv_cmd init - &)"; else echo rbenv not installed; fi
source_if_exists "$HOME/.rbenv/completions/rbenv.bash"

##################################################
# python
##################################################
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
export PIPENV_PYTHON="$PYENV_ROOT/shims/python"
export PYTHONBREAKPOINT="ipdb.set_trace"

# ak replaced '-' with '--path' and added '&'
if command -v pyenv 1>/dev/null 2>&1; then eval "$(pyenv init --path &)"; fi

##################################################
# javascript
##################################################

if which nodenv > /dev/null; then nodenv_cmd="nodenv" ; else nodenv_cmd="/opt/homebrew/bin/nodenv" ; fi
export PATH="$HOME/.nodenv/bin:$PATH"
# ak added &
if which nodenv >/dev/null || test -e $nodenv_cmd ; then eval "$($nodenv_cmd init - &)"; else echo nodenv not installed; fi

##################################################
# fin
##################################################
alias ks=kubectl\ --context=analytics-staging-admin
alias kPROD=kubectl\ --context=analytics-prod-admin
export PATH=$HOME/.datacoral/cli/bin:$PATH
export FIN_SSH_USERNAME="andrew_kortina"
export FIN_CODE_HOME="$HOME/code"
fa_bin="/usr/local/bin/fa"
test -h $fa_bin ||  ln -s "$FIN_CODE_HOME/fin-dev/fa" $fa_bin
