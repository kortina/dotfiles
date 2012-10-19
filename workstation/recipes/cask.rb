execute "brew tap phinze/homebrew-cask" do
    user WS_USER
    command "brew tap phinze/homebrew-cask"
    ignore_failure true # brew tap fails with non-zero output if cask is already installed
end
brew_install "brew-cask"

install_casks = [
    "cyberduck",
    "google-chrome"
]
install_casks.each do |cask|
    execute "brew cask install #{cask}" do
        user WS_USER
        command "brew cask install #{cask}"
    end
end

execute "modify alfred scope for casks" do
    user WS_USER
    command "defaults read com.alfredapp.Alfred scope.paths | grep -q /usr/local/Cellar || defaults write com.alfredapp.Alfred scope.paths -array-add \"/usr/local/Cellar\""
end
