# My setup.

git clone git@github.com:kortina/dotfiles.git
cd dotfiles
git submodule init
git submodule update

Snipmate source is:

git://github.com/msanders/snipmate.vim.git


## Getting the vim plugins to work


### You must rebuild vim 

cd ~/venmo-devops/mac
chmod 700 vim7-install.sh 
sudo env NO_RUNTIME_DOWNLOAD=1 ./vim7-install.sh --enable-perlinterp --enable-pythoninterp --enable-rubyinterp --with-features=huge --enable-gui=no 
sudo mv /usr/bin/vim /usr/bin/vim_original
vim --version

### command-t

cd ~/dotfiles/vim/bundle/command-t/ruby/command-t/
ruby extconf.rb 
make

### pyflakes

cd /tmp
git clone https://github.com/kevinw/pyflakes.git
cd pyflakes
sudo python setup.py install



### exuberant ctags

Download:
http://prdownloads.sourceforge.net/ctags/ctags-5.8.tar.gz
cd ~/Downloads
tar -zxvf ctags-5.8.tar.gz 
cd ctags-5.8
./configure
make
sudo make install
