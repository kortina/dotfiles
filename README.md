### Installation

    git clone git@github.com:kortina/dotfiles.git
    cd dotfiles
    git submodule init
    git submodule update

I think all you should need to do is run the commands in bootstrap.sh, viz;

    gem install soloist
    cd dotfiles/soloist_workstation
    soloist


### pyflakes

    cd /tmp
    git clone https://github.com/kevinw/pyflakes.git
    cd pyflakes
    sudo python setup.py install


### exuberant ctags

    cd ~/Downloads
    wget http://prdownloads.sourceforge.net/ctags/ctags-5.8.tar.gz
    tar -zxvf ctags-5.8.tar.gz 
    cd ctags-5.8
    ./configure
    make
    sudo make install
