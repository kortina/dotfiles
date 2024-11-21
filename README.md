### Installation

    cd ~
    git clone git@github.com:kortina/dotfiles.git
    cd dotfiles
    git submodule update --init
    ./setup.sh

You should see the following output on successful install:

✅ ✅ ✅
🎉 🎉 🎉

NB: If you want s3screenshots, you will need to install following the [README](https://github.com/kortina/dotfiles/tree/master/s3screenshots)

### Docs

You will need to do the following if you are setting up a new machine with MacOS.

At
[generating a new ssh key](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)
do this:

```bash
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

Then open the `~/.ssh` folder and rename the files to:

```bash
mv id_rsa id_ed25519
mv id_rsa.pub id_ed25519.pub
```

Then:

```bash
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
[connecting to GitHub with ssh](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account)

```bash
pbcopy < ~/.ssh/id_ed25519.pub
```

And at [Settings → Keys](https://github.com/settings/keys), paste the new key into the text area.

### Other Pre-Requirements

- Must install Xcode before running `./setup.sh`
- [1Password](https://1password.com/downloads/mac)
- [GitHub](https://github.com/)
  - Copy `~/.sh_secrets` to HOME
- [Google Drive](https://support.google.com/a/users/answer/13022292?hl=en)
  - Set the local path to `~/gd`
  - Set the Drive to `Mirror files`
- **Applications → Screenshot → Options → Show Floating Thumbnail**

### Other Post-Requirements

- [Ad Block Plus for Safari ABP](https://apps.apple.com/us/app/adblock-plus-for-safari-abp/id1432731683?mt=12)
- [Alfred](https://www.alfredapp.com)
  - In Left Bar, choose `Advanced` then `Set preferences folder...` to `~/dotfiles/Alfred-Settings`
- [Cyberduck](https://apps.apple.com/us/app/cyberduck/id409222199?mt=12)
- **brew**
  - `brew install --cask calibre`
- **dotfiles**
  - [dotfiles/ses-emailer-cli](https://github.com/kortina/ses-emailer-cli/) - this SHOULD just work (assuming you have `~/.sh_secrets` setup)
  - [dotfiles/s3screenshots](https://github.com/kortina/dotfiles/tree/master/s3screenshots)
  - [dotfiles/themes/fonts](https://github.com/kortina/dotfiles/tree/master/themes/fonts) - install the MesloLGS NF fonts
  - [src/sq](https://github.com/kortina/sq) - install secrets and run `sq dev project-init dev` eg
- [iStat Menus](https://bjango.com/mac/istatmenus/)
- [Spotify](https://www.spotify.com/de-en/download/mac/)
- System Settings
  - Connect `Google Contacts` in `Internet Accounts`
  - Turn on:
    - `Keyboard`: `Key Repeat Rate` and `Delay Until Repeat`
    - `Keyboard → Keyboard shortcuts...`
      - `Spotlight`: `Show Spotlight search` to `⌥Space`
      - `App Shortcuts`
        - `Safari`
          - `Show Reader` to `⌥R`
          - `Safari Help` to `⌥⇧/`
    - `Reduce Motion`
    - `Reduce Transparency`
    - `Trackpad`: `Tracking speed` and `Click`
    - `Notifications`: `Alfred`
- [Transmission](https://transmissionbt.com/download)
- [VLC](https://www.videolan.org/vlc/)
- [Visual Studio Code](https://code.visualstudio.com/download)
  - Run `> Shell Command: Install 'code' command in PATH`
- [Zoom](https://zoom.us/download)
- Amphetamine
- Resolve

### Details

`setup.sh` will run all of the following setup scripts:

- `setup-homebrew.sh` - install and update homebrew.
- `setup-deps.sh` - install all dependencies, such as `docker` and other libs and packages.
- `setup-symlinks.sh` - create symlinks from your home directory to any files that begin with a `.` in your `~/dotfiles` directory.
- `setup-osx.sh` - configure some osx preferences.

Each of this scripts can also be run independently (which may be faster for making small changes).

### FAQ

- If you get a permissions error, I recommended setting yourself as owner of `/usr/local`:

```
sudo chown -R "`id -u -n`:admin" /usr/local
```

### Themes

```bash
    # install terminal theme
    open "themes/tomorrow-theme/OS X Terminal/Tomorrow Night.terminal"
```

### fzf

`setup-deps.sh` will run `brew install fzf` which creates
`~/.fzf.bash` and `~/.fzf/`. In my `~/.bash_mac` I source `~/.fzf.bash`
to get all of the default terminal keybindings for `fzf` like
`ctrl-r` for history search. Then, I have my personal `fzf` settings
in `~/.fzf.conf.bash`

Last time I setup a machine, I had to run the vim setup to get fzf working...

### Questions

If something is unclear, please add an issue: https://github.com/kortina/dotfiles/issues
