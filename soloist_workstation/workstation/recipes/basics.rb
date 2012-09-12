###
# dotfiles
###
# private
link "#{WS_HOME}/.ssh" do
    to "#{WS_HOME}/Dropbox/nix/ssh"
    owner WS_USER
end
link "#{WS_HOME}/.bash_profile_includes/0_nix.sh" do
    to "#{WS_HOME}/Dropbox/git/dotfiles/.bash_profile_includes/0_nix.sh"
    owner WS_USER
end
link "#{WS_HOME}/.bash_profile_includes/mac.sh" do
    to "#{WS_HOME}/Dropbox/git/dotfiles/.bash_profile_includes/mac.sh"
    owner WS_USER
end

link "#{WS_HOME}/.jenkins" do
    to "#{WS_HOME}/Dropbox/nix/dot_jenkins"
    owner WS_USER
end

# public
link "#{WS_HOME}/.vimrc" do
    to "#{WS_HOME}/Dropbox/git/dotfiles/vimrc"
    owner WS_USER
end
link "#{WS_HOME}/.inputrc" do
    to "#{WS_HOME}/Dropbox/git/dotfiles/inputrc"
    owner WS_USER
end
link "#{WS_HOME}/.ackrc" do
    to "#{WS_HOME}/Dropbox/git/dotfiles/ackrc"
    owner WS_USER
end
link "#{WS_HOME}/.gitconfig" do
    to "#{WS_HOME}/Dropbox/git/dotfiles/gitconfig"
    owner WS_USER
end
link "#{WS_HOME}/.gitignore" do
    to "#{WS_HOME}/Dropbox/git/dotfiles/gitignore"
    owner WS_USER
end
link "#{WS_HOME}/.tmux.conf" do
    to "#{WS_HOME}/Dropbox/git/dotfiles/.tmux.conf"
    owner WS_USER
end

# create dir to hold all uninstalled bundles
remove_to = "#{WS_HOME}/Dropbox/git/dotfiles/vim-pivotal-uninstalled-bundles"
directory "#{remove_to}" do
    owner WS_USER
    action :create
end

# remove these bundles
kortina_removes_pivotal_bundles = [
    "regreplop",
    "command-t" # ctrlp is better
]
kortina_removes_pivotal_bundles.each do |bund|
    bund_path = "#{WS_HOME}/.vim/bundle/#{bund}"
    execute "move #{bund}" do
        command "(test -e #{remove_to}/#{bund} && rm -rf #{remove_to}/#{bund} || test -e #{remove_to}/#{bund}) || mv #{bund_path} #{remove_to}/"
        only_if "test -e #{bund_path}"
    end
end


kortina_vim_bundles = [
    "clang_complete",
    "ctrlp",
    "ir_black_kortina",
    "javaScriptLint",
    "minibufexpl",
    "pep8",
    # "pydiction",
    "pyflakes-vim",
    "taglist",
    "vimux",
    "vim-golang",
    "vim-scratch"
]
kortina_vim_bundles.each do |bund|
    link "#{WS_HOME}/.vim/bundle/#{bund}" do
        to "#{WS_HOME}/Dropbox/git/dotfiles/vim/bundle/#{bund}"
        owner WS_USER
    end
end

kortina_vim_snippets = [
    "_.snippets",
    "pyton.snippets"
]
kortina_vim_snippets.each do |snip|
    link "#{WS_HOME}/.vim/snippets/#{snip}" do
        to "#{WS_HOME}/Dropbox/git/dotfiles/vim/snippets/#{snip}"
        owner WS_USER
    end
end

brew_install "bash-completion"

# install git bash completion
local_path = "/usr/local/etc/bash_completion.d/git-completion.bash"
remote_file local_path do
    user WS_USER
    source "https://raw.github.com/markgandolfo/git-bash-completion/master/git-completion.bash"
    not_if "test -e #{local_path}"
end
