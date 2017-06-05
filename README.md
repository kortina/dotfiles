### Installation

    cd ~
    git clone https://github.com/kortina/dotfiles.git
    cd dotfiles
    git submodule update --init
    ./setup.sh

    cd .vim/plugged/YouCompleteMe/ && ./install.py --tern-completer

You should see the following output on sucessful install:
    
    ✅ ✅ ✅
    🎉 🎉 🎉

NB: If you want s3screenshots, you will need to install following the [README](https://github.com/kortina/dotfiles/tree/master/s3screenshots)

`setup.sh` will run all of the following setup scripts: 

* `setup-homebrew.sh` - install and update homebrew.
* `setup-deps.sh` - install all dependencies, such as `docker` and other libs and packages.
* `setup-symlinks.sh` - create symlinks from your home directory to any files that begin with a `.` in your `~/dotfiles` directory.
* `setup-osx.sh` - configure some osx preferences.

Each of this scripts can also be run independently (which may be faster for making small changes).

### FAQ

* If you get a permissions error, I recommened setting your user as owner of `/usr/local/`:

```
sudo chown -R "`id -u -n`:admin" /usr/local
```

### Other

* Must install Xcode before running `./setup.sh`

### Themes

    # install terminal theme
    open "themes/tomorrow-theme/OS X Terminal/Tomorrow Night.terminal"


### Questions

If something is unclear, please add an issue: https://github.com/kortina/dotfiles/issues
