### Installation

    cd ~
    git clone https://github.com/kortina/dotfiles.git
    cd dotfiles
    git submodule update --init
    ./setup.sh

`setup.sh` will run all of the following setup scripts: 

* `setup-homebrew.sh` - install and update homebrew.
* `setup-deps.sh` - install all dependencies, such as `docker` and other libs and packages.
* `setup-symlinks.sh` - create symlinks from your home directory to any files that begin with a `.` in your `~/dotfiles` directory.
* `setup-osx.sh` - configure some osx preferences.

Each of this scripts can also be run independently (which may be faster for making small changes).

### Other

* Must install Xcode before running `./setup.sh`
* Other things I install on a mac: Alfred, Caffeine, Chrome, Divvy, Dropbox

### Questions

If something is unclear, please add an issue: https://github.com/kortina/dotfiles/issues
