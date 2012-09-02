# My setup.

git clone git@github.com:kortina/dotfiles.git
cd dotfiles
git submodule init
git submodule update


I am in the middle of transitioning from using my vim bundles folder here to the vim bundles in the pivotal_workstation, as they are pretty good and seem to work out of the box.

I think all you should need to do now is run the commands in bootstrap.sh, viz;

    gem install soloist
    cd dotfiles/soloist_workstation
    soloist


...


Snipmate source is:

git://github.com/msanders/snipmate.vim.git


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



### submodules

git submodule add https://github.com/vim-scripts/gnupg.vim.git vim/bundle/gnupg
