### Installation

    cd ~
    git clone https://github.com/kortina/dotfiles.git
    cd dotfiles
    git submodule update --init
    ./setup.sh

`setup.sh` will run all of the following setup scripts: 

* `setup-deps.sh` - install all dependencies, such as `homebrew`, `docker`, and other libs and packages.
* `setup-symlinks.sh` - create symlinks from your home directory to any files that begin with a `.` in your `~/dotfiles` directory.
* `setup-osx.sh` - configure some osx preferences.

### Dependencies

Some dependencies installed via `setup-deps.sh`

* ctags
* flake8
* tmux
* powerline
* probably a few other things

### Questions

If something is unclear, please add an issue: https://github.com/kortina/dotfiles/issues
