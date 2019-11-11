#!/usr/bin/env bash
set -e
echo "##### $(basename $BASH_SOURCE) #####"

# supporting function and export VAR declarations for other setup
# scripts and ~/.bash_profile


########################################
# common exports
########################################
export VSCODE_APP="/Applications/Visual Studio Code.app"
DOTFILES_ROOT="`pwd`"

########################################
# formatting functions
# https://gist.github.com/jonlabelle/7093921
########################################
# show a cyan `OK!`, or arg `1` message
function show_info()
{
  local msg="OK!"
  if [ ! -z "$1" ]; then
    msg="$1"
  fi
  echo -e "\033[0;36m${msg}\033[0m"
}

export -f show_info

# show a magneta `OK!`, or arg `1` message
function show_info_alt()
{
  local msg="OK!"
  if [ ! -z "$1" ]; then
    msg="$1"
  fi
  echo -e "\033[0;35m${msg}\033[0m"
}

export -f show_info_alt

# show a green `Success!`, or arg `1` message
function show_success()
{
  local msg="Success!"
  if [ ! -z "$1" ]; then
    msg="$1"
  fi
  echo -e "\033[0;32m${msg}\033[0m"
}

export -f show_success

# show a yellow `Warning!`, or arg `1` message
function show_warning()
{
  local msg="Warning!"
  if [ ! -z "$1" ]; then
    msg="$1"
  fi
  echo -e "\033[0;33m${msg}\033[0m"
}

export -f show_warning

# show a red `Error!`, or arg `1` message
function show_error()
{
  local msg="Error!"
  if [ ! -z "$1" ]; then
    msg="$1"
  fi
  echo -e "\033[0;31m${msg}\033[0m"
}

export -f show_error

########################################
########################################


function safely_symlink() {
    sym_file="$1" # the symlink we are creating, full path, /Users/kortina/.ssh/config
    targ_file="$2" # the file the symlink points to, /Users/kortina/dotfiles/.ssh/config
    sym_dir="$3" # directory containining symlink we are creating, no trailing /, /Users/kortina/.ssh

    if test -h "$sym_file" || ! test -e "$sym_file"; then
        if ! test -d "$sym_dir"; then
            show_warning "WARNING: Directory you are trying to symlink from does not exist: $sym_dir"
        else
            # no file or another symlink exists. OK TO OVERWRITE 
            echo "ln -fs $targ_file $sym_dir/"
            ln -fs "$targ_file" "$sym_dir/"
        fi
    else
        show_error "\nABORT: file exists and is not a link:\n\"$sym_file\""
        exit 1
    fi
}

export -f safely_symlink

