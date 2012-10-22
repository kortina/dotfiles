dotfiles_path = File.expand_path(File.dirname(__FILE__)+"../../..") # a few levels up from this file

if WS_USER == "kortina"
    link "#{WS_HOME}/.bash_profile_includes/0_nix.sh" do
        to "#{dotfiles_path}/.bash_profile_includes/0_nix.sh"
        owner WS_USER
    end
    link "#{WS_HOME}/.bash_profile_includes/mac.sh" do
        to "#{dotfiles_path}/.bash_profile_includes/mac.sh"
        owner WS_USER
    end

    link "#{WS_HOME}/.jenkins" do
        to "#{WS_HOME}/Dropbox/nix/dot_jenkins"
        owner WS_USER
    end
    link "#{WS_HOME}/.ssh" do
        to "#{WS_HOME}/Dropbox/nix/ssh"
        owner WS_USER
    end
end
