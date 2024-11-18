### Installation

    cd ~
    git clone git@github.com:kortina/dotfiles.git
    cd dotfiles
    git submodule update --init
    ./setup.sh

You should see the following output on sucessful install:
  
✅ ✅ ✅
🎉 🎉 🎉

NB: If you want s3screenshots, you will need to install following the [README](https://github.com/kortina/dotfiles/tree/master/s3screenshots)

### TODO

You will need to do the following if you are setting up a new machine with MacOS.


At
<https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent>
do this:


```
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

Then open the `~/.ssh` folder and rename the files to:

```
mv id_rsa id_ed25519
mv id_rsa.pub id_ed25519.pub
```


Then:

```
eval "$(ssh-agent -s)"
> Agent pid 59566

touch ~/.ssh/config
Host github.com
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519

ssh-add --apple-use-keychain ~/.ssh/id_ed25519
```

Then at
<https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account>


```
pbcopy < ~/.ssh/id_ed25519.pub
```

And at <https://github.com/settings/keys>, paste the new key into the text area.


### Details

`setup.sh` will run all of the following setup scripts:

- `setup-homebrew.sh` - install and update homebrew.
- `setup-deps.sh` - install all dependencies, such as `docker` and other libs and packages.
- `setup-symlinks.sh` - create symlinks from your home directory to any files that begin with a `.` in your `~/dotfiles` directory.
- `setup-osx.sh` - configure some osx preferences.

Each of this scripts can also be run independently (which may be faster for making small changes).

### FAQ

- If you get a permissions error, I recommened setting yourself as owner of `/usr/local`:

```
sudo chown -R "`id -u -n`:admin" /usr/local
```

### Themes

    # install terminal theme
    open "themes/tomorrow-theme/OS X Terminal/Tomorrow Night.terminal"

### fzf

`setup-deps.sh` will run `brew install fzf` which creates
`~/.fzf.bash` and `~/.fzf/`. In my `~/.bash_mac` I source `~/.fzf.bash`
to get all of the default terminal keybindings for `fzf` like
`ctrl-r` for history search. Then, I have my personal `fzf` settings
in `~/.fzf.conf.bash`

Last time I setup a machine, I had to run the vim setup to get fzf working...

### Other

- Must install Xcode before running `./setup.sh`
- Chrome
- Alfred
- Amphetamine
- Cyberduck
- Resolve


### Questions

If something is unclear, please add an issue: https://github.com/kortina/dotfiles/issues
