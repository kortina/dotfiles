###
# dotfiles
###
link "#{node[:HOME]}/.ssh" do
    to "#{node[:HOME]}/Dropbox/nix/ssh"
    owner node[:workstation_user]
end
link "#{node[:HOME]}/.bash_profile_includes/kortina_mac.sh" do
    to "#{node[:HOME]}/Dropbox/nix/bash_profile.sh"
    owner node[:workstation_user]
end
link "#{node[:HOME]}/.vimrc" do
    to "#{node[:HOME]}/Dropbox/git/dotfiles/vimrc"
    owner node[:workstation_user]
end
link "#{node[:HOME]}/.inputrc" do
    to "#{node[:HOME]}/Dropbox/git/dotfiles/inputrc"
    owner node[:workstation_user]
end
link "#{node[:HOME]}/.ackrc" do
    to "#{node[:HOME]}/Dropbox/git/dotfiles/ackrc"
    owner node[:workstation_user]
end
link "#{node[:HOME]}/.gitconfig" do
    to "#{node[:HOME]}/Dropbox/git/dotfiles/gitconfig"
    owner node[:workstation_user]
end
link "#{node[:HOME]}/.gitignore" do
    to "#{node[:HOME]}/Dropbox/git/dotfiles/gitignore"
    owner node[:workstation_user]
end

kortina_vim_bundles = [
    "ir_black_kortina",
    "javaScriptLint",
    "minibufexpl",
    "pep8",
    "pydiction",
    "pyflakes-vim",
    "taglist",
    "vim-golang"
]
kortina_vim_bundles.each do |bund|
    link "#{node[:HOME]}/.vim/bundle/#{bund}" do
        to "#{node[:HOME]}/Dropbox/git/dotfiles/vim/bundle/#{bund}"
        owner node[:workstation_user]
    end
end

kortina_vim_snippets = [
    "_.snippets",
    "pyton.snippets"
]
kortina_vim_snippets.each do |snip|
    link "#{node[:HOME]}/.vim/snippets/#{snip}" do
        to "#{node[:HOME]}/Dropbox/git/dotfiles/vim/snippets/#{snip}"
        owner node[:workstation_user]
    end
end
