## My Setup

Create a link in the home directory for each file that matches the pattern
`.symlink`.  The links that get created strip off the `.symlink` and everything
after.

### Installation

./install.sh

#### Clone this module and init the submodules

    git clone git://github.com/kortina/dotfiles.git # OR: git clone git@github.com:kortina/dotfiles.git
    cd dotfiles
    git submodule init
    git submodule update

I think all you should need to do is run the commands in bootstrap.sh, viz,

    gem install soloist
    cd dotfiles
    soloist


