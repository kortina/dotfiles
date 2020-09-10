export BASH_SILENCE_DEPRECATION_WARNING=1

source $HOME/.profile


shopt -s histappend
# use option delete to delete previous word
bind '"\M-d": backward-kill-word'
# use ctrl-k to completely clear the screen / delete scroll history, like ⌘+k in mac terminal
bind '"\C-k": "printf \\\\33c\\\\e[3;\n"'

##################################################
# pretty bash prompt with git / svn branch name
##################################################
source /usr/local/opt/gitstatus/gitstatus.prompt.sh
# PS1='\w ${GITSTATUS_PROMPT}\n\$ ' # directory followed by git status and $/# (normal/root)
PS1="\n\
\[\033[0;32m\]\u$DIM \[\033[0;37m\]@ \[\033[0;33m\]\h 
\[\033[0;35m\]\$PWD \[\033[0;37m\]\${GITSTATUS_PROMPT}$ " && export PS1


##################################################
# bash completion
##################################################
brew_prefix="/usr/local" # output of `brew --prefix`
source_if_exists "$brew_prefix/etc/bash_completion"
source_if_exists "$brew_prefix/etc/bash_completion.d/rails.bash"
command_exists kubectl && source <(kubectl completion bash) &

##################################################
# fzf
##################################################
source_if_exists "$HOME/.fzf.bash"
source_if_exists "$HOME/.fzf.conf.bash"

##################################################
# fin
##################################################
eval "$(_FA_COMPLETE=source fa)"

# function make-completion-wrapper () {
#   local function_name="$2"
#   local arg_count=$(($#-3))
#   local comp_function_name="$1"
#   shift 2
#   local function="
#     function $function_name {
#       ((COMP_CWORD+=$arg_count))
#       COMP_WORDS=( "$@" \${COMP_WORDS[@]:1} )
#       "$comp_function_name"
#       return 0
#     }"
#   eval "$function"
#   echo $function_name
#   echo "$function"
# }
