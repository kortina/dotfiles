## My Setup

The installer creates symlinks in `~/` to each file matches the pattern
`.symlink` and to the `vim` directory.

### Installation

    git clone https://github.com/kortina/dotfiles.git
    cd dotfiles
    git submodule update --init
    ./install.sh

### Dependencies

I use these dotfiles in conjunction with boxen ( https://github.com/kortina/our-boxen ) to configure my machine.  For all of the vim plugins to work, there are some dependencies that I install via boxen, like:

* ctags
* flake8
* tmux
* powerline
* probably a few other things


### Questions

If something is unclear, please add an issue: https://github.com/kortina/dotfiles/issues
