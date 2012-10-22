## My Setup

Some of the symlinks created in the basics.rb recipe are specific to my setup
(eg, my Dropbox folder with some private files). Most of the other stuff is
generic.  I recently found the awesome pivotal workstation soloist repo, which
is a great base for configuring a new mac and replaced much of my old setup.

### Installation

#### Pre-Reqs

    ruby -e "$(curl -fsSkL raw.github.com/mxcl/homebrew/go)" # install homebrew
    brew doctor

#### Clone this module and init the submodules

    git clone git://github.com/kortina/dotfiles.git # OR: git clone git@github.com:kortina/dotfiles.git
    cd dotfiles
    git submodule init
    git submodule update

I think all you should need to do is run the commands in bootstrap.sh, viz,

    gem install soloist
    cd dotfiles
    soloist


