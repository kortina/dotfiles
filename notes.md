# Sublime Text Config
* [Launch Sublime from Terminal](https://gist.github.com/martinbuberl/5823ed247d279d1a2d06) - Sublime Text includes a command line tool, subl, to work with files on the command line. This can be used to open files and projects in Sublime Text, as well working as an EDITOR for unix tools, such as git and subversion.
* [Standard JS Formatter](https://github.com/feross/standard#sublime-text) - JavaScript Style Guide, with linter & automatic code fixer 
* [Default Tab Size](https://www.sublimetext.com/docs/2/indentation.html): (Sublime Text > Preferences > Settings)

        {
          "tab_size": 2,
          "translate_tabs_to_spaces": true
        }
* [Configuring LaTeX](http://economistry.com/2013/01/installing-and-using-latex-for-mac/): LaTeX is the standard typesetting for economists. Equations are easier to type, making citations is a breeze, and your finished paper just looks more beautiful.

# Other
* [Reply from any email address](https://ellisbenus.com/web-design-columbia-mo/workaround-using-gmail-alias-forwarded-email-addresses/) - Gmail hack to be able to reply from any domain you own.
* [Open new Terminal tab in current working directory doesn't work](https://apple.stackexchange.com/questions/144896/open-new-terminal-tab-in-current-working-directory-doesnt-work) - Make sure terminal windows open in same folder if tab and root folder if new window
* [Git keeps asking for password](http://stackoverflow.com/questions/7773181/git-keeps-prompting-me-for-password) - For macOS 10.12 Sierra ssh-add -K needs to be run after every reboot. To avoid this create ~/.ssh/config with this content:

        Host *
          AddKeysToAgent yes
          UseKeychain yes
          IdentityFile ~/.ssh/id_rsa