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

# remove these bundles (created by pivotal recipe)
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

# remove these bash includes (created by pivotal recipe)
kortina_removes_pivotal_bash_includes = [
    "rvm.sh",
    "vi_is_minimal_vim.sh",
    "vim_tmux.sh"
]
kortina_removes_pivotal_bash_includes.each do |sh|
    sh_path = "#{WS_HOME}/.bash_profile_includes/#{sh}"
    execute "remove #{sh}" do
        command "rm #{sh_path}"
        only_if "test -e #{sh_path}"
    end
end


kortina_vim_bundles = [
    "a.vim",
    "clang_complete",
    "cocoa.vim",
    "ctrlp",
    "ir_black_kortina",
    "javaScriptLint",
    "minibufexpl",
    "pep8",
    # "pydiction",
    "pyflakes-vim",
    "taglist",
    "vimux",
    "vim-commentary",
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

directory "#{WS_HOME}/bin" do
    owner WS_USER
    action :create
end

=begin
brew_install "geoip"
local_path = "/usr/local/share/GeoIP/GeoLiteCity.dat"
remote_file local_path do
    user WS_USER
    source "http://www.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz"
    not_if "test -e #{local_path}"
end
=end

brew_install "ack"
brew_install "bash-completion"

# install git bash completion
local_path = "/usr/local/etc/bash_completion.d/git-completion.bash"
remote_file local_path do
    user WS_USER
    source "https://raw.github.com/markgandolfo/git-bash-completion/master/git-completion.bash"
    not_if "test -e #{local_path}"
end

xcode_theme_dir = "#{WS_HOME}/Library/Developer/Xcode/UserData/FontAndColorThemes" 
directory xcode_theme_dir do
  owner WS_USER
  mode "0755"
  action :create
  recursive true
end

execute "install color themes for xcode" do
    user WS_USER
    command "cp #{WS_HOME}/Dropbox/git/dotfiles/xcode-themes/* #{xcode_theme_dir}/"
end
