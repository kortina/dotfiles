## My Setup

`dotbuild` installer will aggregate all files found in `dotfiles-*` directories
into a `build` directory and then create symlinks from user home directory to
`build` directory.

### Installation

    git clone https://github.com/kortina/dotfiles.git
    cd dotfiles
    git submodule update --init
    dotbuild

### Dependencies

I use these dotfiles in conjunction with dotbuild and boxen ( https://github.com/kortina/our-boxen ) to configure my machine.  For all of the vim plugins to work, there are some dependencies that I install via boxen, like:

* dotbuild
* ctags
* flake8
* tmux
* powerline
* probably a few other things


### Questions

If something is unclear, please add an issue: https://github.com/kortina/dotfiles/issues
